require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { GoogleGenerativeAI } = require('@google/generative-ai');

const app = express();

// Permite que o Delphi acesse a API
app.use(cors({ origin: '*' }));
app.use(express.json());

// Inicializa a IA com a chave do .env
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// Retry automático com espera exponencial — APENAS para rate limit (429)
async function gerarComRetry(model, comando, tentativas = 4) {
    for (let i = 0; i < tentativas; i++) {
        try {
            const result = await model.generateContent(comando);
            return result.response.text();
        } catch (error) {
            const e429 = error.status === 429;
            const ultimaTentativa = i === tentativas - 1;

            // Só tenta novamente se for 429 e ainda tiver tentativas
            if (e429 && !ultimaTentativa) {
                const espera = (i + 1) * 5000; // 5s, 10s, 15s...
                console.warn(`[429] Rate limit. Tentativa ${i + 1}/${tentativas}. Aguardando ${espera / 1000}s...`);
                await new Promise(r => setTimeout(r, espera));
            } else {
                // Para qualquer outro erro falha imediatamente
                throw error;
            }
        }
    }
}

app.post('/api/soul/delphi', async (req, res) => {
    try {
        const { comando } = req.body;
        if (!comando) return res.status(400).json({ success: false, erro: 'Comando vazio.' });

        console.log(`[Antigravity] Recebeu comando: ${comando}`);

        const model = genAI.getGenerativeModel({
            model: "gemini-2.0-flash",
            systemInstruction: `Você é uma IA nativa de uma IDE Delphi 13.
Gere APENAS o código Pascal/Delphi para ser injetado DIRETAMENTE no editor.
REGRAS:
1. Retorne APENAS o código puro. Nenhum texto antes ou depois.
2. NÃO use blocos de formatação markdown (nunca use \`\`\`pascal ou \`\`\`).
3. NÃO inclua explicações ou saudações.
4. O código deve estar perfeitamente indentado (use 2 espaços).`
        });

        let codigoGerado = await gerarComRetry(model, comando);

        // Filtro de Segurança
        codigoGerado = codigoGerado.replace(/^```pascal\n/im, '');
        codigoGerado = codigoGerado.replace(/^```delphi\n/im, '');
        codigoGerado = codigoGerado.replace(/^```\n/im, '');
        codigoGerado = codigoGerado.replace(/```$/im, '');

        res.json({ success: true, codigo: codigoGerado });

    } catch (error) {
        console.error("[Erro na Soul]:", error);

        if (error.status === 429) {
            return res.status(429).json({
                success: false,
                erro: 'Serviço sobrecarregado após múltiplas tentativas. Aguarde 1 minuto.'
            });
        }

        res.status(500).json({ success: false, erro: error.message });
    }
});

// Liga o servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 Conect IA Soul rodando na porta ${PORT}`);
});
