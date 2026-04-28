require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { GoogleGenerativeAI } = require('@google/generative-ai');

const app = express();
app.use(cors({ origin: '*' }));
app.use(express.json());

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

app.post('/api/soul/delphi', async (req, res) => {
    // Resposta em pedaços — o Delphi recebe token a token em tempo real
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    res.setHeader('Transfer-Encoding', 'chunked');

    try {
        const { comando } = req.body;
        if (!comando) return res.end();

        console.log(`[Antigravity Soul] Streaming para o Gemini...`);

        const model = genAI.getGenerativeModel({
            model: "gemini-2.0-flash",
            systemInstruction: `Você é uma IA de Delphi 13.
REGRAS ESTRITAS:
1. Retorne APENAS o código. Sem explicações ou saudações.
2. NUNCA use marcações markdown (não use \`\`\`pascal).
3. NENHUMA INDENTAÇÃO. Retorne TODO o código alinhado 100% à esquerda. A IDE fará a indentação.`
        });

        const streamResult = await model.generateContentStream(comando);

        for await (const chunk of streamResult.stream) {
            const token = chunk.text();
            if (token) {
                res.write(token); // Envia cada pedaço instantaneamente pro Delphi
            }
        }
        res.end();

    } catch (error) {
        console.error("[Erro na Soul - Google]:", error.message);

        if (error.status === 429) {
            res.write('// Rate limit atingido. Aguarde alguns segundos.');
        } else {
            res.write(`// Erro: ${error.message}`);
        }
        res.end();
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`🚀 Conect IA Soul (GEMINI STREAMING) na porta ${PORT}`));
