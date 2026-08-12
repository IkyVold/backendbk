// services/aiChatService.js
// AI chatbot menggunakan Ollama lokal di VPS
// Jawaban chatbot HANYA berdasarkan informasi yang diberikan Guru BK.

const axios = require('axios');
const informasiModel = require('../models/informasiModel');
const HttpError = require('../utils/HttpError');
const { sanitizeMessages } = require('../utils/sanitize');

const OUT_OF_SCOPE_MESSAGE =
    'Maaf, saya belum memiliki informasi yang sesuai untuk pertanyaan tersebut. ' +
    'Silakan tanyakan hal yang berkaitan dengan informasi sekolah atau konseling yang telah diberikan oleh Guru BK.';

async function chatWithAI(messages) {

    // =============================================================
    // VALIDASI PESAN
    // =============================================================

    if (!messages || !Array.isArray(messages)) {
        const err = new HttpError(400, 'Format pesan tidak valid');

        err.payload = {
            error: {
                message: 'Format pesan tidak valid'
            }
        };

        throw err;
    }

    console.log('📨 Chat request received');

    // =============================================================
    // AMBIL PESAN USER TERAKHIR
    // =============================================================

    const lastUserMessage = messages
        .filter(m => m.role === 'user')
        .pop();

    if (!lastUserMessage || !lastUserMessage.content) {
        const err = new HttpError(400, 'Pesan tidak boleh kosong');

        err.payload = {
            error: {
                message: 'Pesan tidak boleh kosong'
            }
        };

        throw err;
    }

    const question = String(lastUserMessage.content).trim();

    console.log('📝 Pertanyaan diterima (isi disembunyikan)');

    // =============================================================
    // AMBIL SEMUA INFORMASI DARI GURU BK
    // =============================================================

    let infoRows = [];

    try {

        infoRows = await informasiModel.listForChatbot();

    } catch (e) {

        console.error(
            '❌ Gagal mengambil informasi_bk:',
            e.message
        );

        const err = new HttpError(
            500,
            'Gagal mengambil informasi dari Guru BK'
        );

        err.payload = {
            error: {
                message: 'Gagal mengambil informasi dari Guru BK'
            }
        };

        throw err;
    }

    // =============================================================
    // JIKA BELUM ADA INFORMASI DARI GURU BK
    // =============================================================

    if (!infoRows || infoRows.length === 0) {

        console.log('⚠️ Belum ada informasi Guru BK');

        return {
            reply: OUT_OF_SCOPE_MESSAGE,
            success: true
        };
    }

    // =============================================================
    // BUAT REFERENSI FAQ
    // =============================================================

    const referensiText = infoRows
        .map(
            r =>
                `### ${r.judul} (${r.kategori})\n${r.isi}`
        )
        .join('\n\n');

    // =============================================================
    // SYSTEM PROMPT
    //
    // PENTING:
    // MODEL DILARANG MENGGUNAKAN PENGETAHUAN UMUMNYA.
    // SEMUA JAWABAN HARUS BERASAL DARI REFERENSI.
    // =============================================================

    const counselingSystemPrompt = {
        role: 'system',

        content: `
Anda adalah chatbot informasi dan konseling sekolah.

SUMBER INFORMASI ANDA HANYA:
Informasi yang diberikan oleh Guru BK pada bagian REFERENSI di bawah.

ATURAN PALING PENTING:

1. Anda DILARANG menggunakan pengetahuan umum dari model AI.
2. Anda DILARANG menjawab berdasarkan pengetahuan yang Anda miliki di luar REFERENSI.
3. Anda DILARANG mengarang informasi.
4. Anda DILARANG menambahkan fakta, nama, tanggal, angka, syarat, link, alamat, atau informasi lain yang tidak terdapat dalam REFERENSI.
5. Jika jawaban atas pertanyaan siswa TIDAK terdapat atau TIDAK dapat disimpulkan secara langsung dari REFERENSI, JANGAN menjawab berdasarkan pengetahuan umum.
6. Jika informasi tidak tersedia, jawab persis dengan:

"Maaf, saya belum memiliki informasi yang sesuai untuk pertanyaan tersebut. Silakan tanyakan hal yang berkaitan dengan informasi sekolah atau konseling yang telah diberikan oleh Guru BK."

7. Gunakan bahasa Indonesia yang sederhana, sopan, dan mudah dipahami siswa.
8. Jangan menyebutkan bahwa Anda menggunakan model AI.
9. Jangan membahas topik di luar informasi yang diberikan Guru BK.
10. Jika pertanyaan hanya basa-basi seperti "halo", "hai", atau "selamat pagi", boleh membalas secara singkat dan mengarahkan siswa untuk menanyakan informasi yang tersedia.
11. Jika pertanyaan berkaitan dengan konseling tetapi REFERENSI tidak memberikan informasi yang cukup, gunakan jawaban penolakan yang telah ditentukan.
12. Jangan mengambil informasi dari percakapan sebelumnya jika informasi tersebut tidak terdapat dalam REFERENSI.

==================================================
REFERENSI INFORMASI DARI GURU BK
==================================================

${referensiText}

==================================================
AKHIR REFERENSI
==================================================

SEBELUM MENJAWAB:

Periksa terlebih dahulu apakah pertanyaan siswa dapat dijawab menggunakan REFERENSI.

Jika YA:
- Jawab hanya berdasarkan REFERENSI.
- Jangan menambahkan informasi dari pengetahuan umum.

Jika TIDAK:
- Jangan menjawab pertanyaan tersebut.
- Gunakan jawaban penolakan yang telah ditentukan.

Ingat:
REFERENSI adalah satu-satunya sumber kebenaran.
`
    };

    // =============================================================
    // SANITASI PESAN
    // =============================================================

    const safeMessages = sanitizeMessages(messages);

    // =============================================================
    // HISTORY TIDAK BOLEH MENGALAHKAN SYSTEM PROMPT
    // =============================================================

    const finalMessages = [
        counselingSystemPrompt,
        ...safeMessages
    ];

    // =============================================================
    // PANGGIL OLLAMA
    // =============================================================

    const ollamaUrl =
        process.env.OLLAMA_URL ||
        'http://127.0.0.1:11434/api/chat';

    const ollamaModel =
        process.env.OLLAMA_MODEL ||
        'llama3.2:3b';

    try {

        console.log(
            `🤖 Menggunakan Ollama: ${ollamaModel}`
        );

        const response = await axios.post(
            ollamaUrl,
            {
                model: ollamaModel,

                messages: finalMessages,

                stream: false,

                options: {
                    temperature: 0.1,
                    num_predict: 256
                }
            },
            {
                headers: {
                    'Content-Type': 'application/json'
                },

                timeout: 120000
            }
        );

        // =========================================================
        // AMBIL RESPONSE
        // =========================================================

        let reply =
            response.data?.message?.content?.trim();

        if (!reply) {
            reply = OUT_OF_SCOPE_MESSAGE;
        }

        console.log(
            '✅ Chat response dari Ollama dikirim'
        );

        return {
            reply,
            success: true
        };

    } catch (error) {

        console.error(
            '❌ OLLAMA API Error:',
            error.response?.data || error.message
        );

        let errorMessage =
            'Maaf, terjadi kesalahan pada server. Silakan coba lagi nanti.';

        if (error.code === 'ECONNABORTED') {

            errorMessage =
                'Maaf, koneksi ke layanan AI timeout. Silakan coba lagi.';
        }

        if (error.code === 'ECONNREFUSED') {

            errorMessage =
                'Maaf, layanan AI sedang tidak tersedia.';
        }

        if (error.response?.status === 404) {

            errorMessage =
                'Maaf, model AI tidak ditemukan di server.';
        }

        if (error.response?.status >= 500) {

            errorMessage =
                'Maaf, layanan AI sedang mengalami gangguan.';
        }

        const status =
            error.response?.status || 500;

        const err = new HttpError(
            status,
            errorMessage
        );

        err.payload = {
            error: {
                message: errorMessage,
                status
            }
        };

        throw err;
    }
}

module.exports = {
    chatWithAI
};