const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors({ origin: '*' }));
app.use(express.json());

// ─────────────────────────────────────────────────────────────
// Formatter de indentação Delphi/Pascal
// ─────────────────────────────────────────────────────────────
function formatarDelphi(codigoBruto) {
    let codigo = codigoBruto.replace(/^```[a-zA-Z]*\s*$/gm, '').trim();
    const linhas = codigo.split('\n');
    let nivel = 0;
    let emImpl = false;   // estamos na seção implementation?
    let classDepth = 0;   // profundidade de classes aninhadas
    let varPendente = false; // var/const antes de begin?
    const resultado = [];

    for (const raw of linhas) {
        const linha = raw.trim();
        if (!linha) { resultado.push(''); continue; }

        if (/^(\/\/|{|\(\*)/.test(linha)) {
            resultado.push('  '.repeat(nivel) + linha);
            continue;
        }

        const lo = linha.toLowerCase().replace(/'[^']*'/g, '');

        let dec = 0;
        let inc = 0;

        // ── Seções de unit ──
        if (/^(implementation|initialization|finalization)\b/.test(lo)) {
            emImpl = true;
            classDepth = 0;
            varPendente = false;
            dec = nivel; // reseta para 0
        }

        // ── procedure/function/constructor/destructor como IMPLEMENTAÇÃO (fora de class) ──
        if (/^(procedure|function|constructor|destructor)\b/.test(lo) && emImpl && classDepth === 0) {
            if (varPendente) varPendente = false;
            dec = nivel; // reseta para 0
        }

        // ── end ──
        if (/^end\b/.test(lo)) {
            dec++;
            if (classDepth > 0) classDepth--;
            if (varPendente) { varPendente = false; dec++; }
        }

        // ── finally / except ──
        if (/^(finally|except)\b/.test(lo)) { dec++; inc++; }

        // ── until ──
        if (/^until\b/.test(lo)) dec++;

        // ── private/public/protected/published ──
        if (/^(private|public|protected|published)\b/.test(lo)) { dec++; inc++; }

        // ── begin ──
        if (/\bbegin\b/.test(lo)) {
            if (varPendente) { varPendente = false; dec++; }
            inc++;
        }

        // ── try ──
        if (/^try\b/.test(lo)) inc++;

        // ── repeat ──
        if (/^repeat\b/.test(lo)) inc++;

        // ── var/const/type isolado ──
        if (/^(var|const|type)\s*$/.test(lo)) {
            if (lo.trim() === 'var' || lo.trim() === 'const') {
                varPendente = true;
            }
            inc++;
        }

        // ── class ──
        if (/\bclass\b/.test(lo) && !/^end\b/.test(lo) && !/;\s*$/.test(lo.replace(/\s/g,''))) {
            classDepth++;
            inc++;
        }
        // class com ; no final (ex: TFoo = class;) → forward declaration, não abre bloco
        // Tratado pela condição acima: !/;\s*$/ impede inc

        // ── record ──
        if (/\brecord\b/.test(lo) && !/^end\b/.test(lo)) inc++;

        // ── case ... of ──
        if (/^case\b/.test(lo) && /\bof\b/.test(lo)) inc++;

        // Aplica
        nivel = Math.max(0, nivel - dec);
        resultado.push('  '.repeat(nivel) + linha);
        nivel += inc;
    }

    return resultado.join('\n');
}

// ─────────────────────────────────────────────────────────────
// Rota principal
// ─────────────────────────────────────────────────────────────
app.post('/api/soul/delphi', async (req, res) => {
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');

    let ollamaResponse;

    req.on('close', () => {
        if (ollamaResponse && ollamaResponse.body) {
            ollamaResponse.body.cancel().catch(() => {});
        }
    });

    try {
        const { comando } = req.body;
        if (!comando) return res.end();

        console.log(`[Antigravity Soul] Aguardando resposta do Ollama...`);

        try {
            ollamaResponse = await fetch('http://127.0.0.1:11434/api/generate', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    model: "qwen2.5-coder:3b",
                    prompt: comando,
                    system: `Você é um gerador de código Delphi/Pascal puro.
REGRAS: retorne SOMENTE o código-fonte. Sem markdown, sem explicações, sem crases.`,
                    stream: true,
                    keep_alive: "5m",
                    options: { num_ctx: 2048, num_predict: 1024 }
                })
            });
        } catch (fetchErr) {
            console.error("[Erro] Ollama não está acessível:", fetchErr.message);
            return res.status(503).send('// ERRO: O Ollama não está rodando.');
        }

        if (!ollamaResponse.ok) {
            const errBody = await ollamaResponse.text().catch(() => '(sem body)');
            console.error(`[Erro] Ollama retornou: ${ollamaResponse.status} → ${errBody}`);
            return res.status(502).send(`// ERRO: Ollama ${ollamaResponse.status}: ${errBody}`);
        }

        const reader = ollamaResponse.body.getReader();
        const decoder = new TextDecoder();
        let textoCompleto = '';

        try {
            while (true) {
                const { done, value } = await reader.read();
                if (done) break;
                const chunk = decoder.decode(value, { stream: true });
                for (const jsonLine of chunk.split('\n').filter(l => l.trim())) {
                    try {
                        const json = JSON.parse(jsonLine);
                        if (json.response) textoCompleto += json.response;
                    } catch (e) {}
                }
            }
        } finally {
            reader.releaseLock();
        }

        const codigoFormatado = formatarDelphi(textoCompleto);
        console.log('[Antigravity Soul] Concluído. Enviando código formatado.');
        if (!res.writableEnded) res.send(codigoFormatado);

    } catch (error) {
        console.error("[Erro na Soul - Ollama]:", error.message);
        if (!res.headersSent) res.status(500).send('// Erro interno.');
        else if (!res.writableEnded) res.end();
    }
});

const PORT = 3000;
app.listen(PORT, () => console.log(`🚀 Conect IA Soul (OLLAMA) na porta ${PORT}`));