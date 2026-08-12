// services/aiChatService.js
// AI chatbot menggunakan Ollama lokal di VPS

const axios = require('axios');
const informasiModel = require('../models/informasiModel');
const HttpError = require('../utils/HttpError');
const { sanitizeMessages } = require('../utils/sanitize');

async function chatWithAI(messages) {
    if (!messages || !Array.isArray(messages)) {
        // Bentuk error sama seperti response lama
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
    // AMBIL PESAN TERAKHIR USER
    // =============================================================

    const lastUserMessage = messages
        .filter(m => m.role === 'user')
        .pop();

    if (lastUserMessage) {
        // Isi pesan sengaja tidak dicetak untuk menjaga privasi
        console.log('📝 Chat request diterima (isi disembunyikan)');
    }

    // =============================================================
    // AMBIL KNOWLEDGE BASE FAQ DARI GURU BK
    // =============================================================

    let referensiText = '(Belum ada informasi tambahan dari Guru BK)';

    try {
        const infoRows = await informasiModel.listForChatbot();

        if (infoRows.length > 0) {
            referensiText = infoRows
                .map(
                    r =>
                        `### ${r.judul} (${r.kategori})\n${r.isi}`
                )
                .join('\n\n');
        }
    } catch (e) {
        console.warn(
            'Gagal ambil informasi_bk untuk konteks chatbot:',
            e.message
        );
    }

    // =============================================================
    // SYSTEM PROMPT
    // =============================================================

    const counselingSystemPrompt = {
        role: 'system',

        content: `Anda adalah konselor BK profesional untuk siswa SMP/SMA.

BATASAN KETAT - HANYA 6 KATEGORI KONSELING SEKOLAH INI:

1. AKADEMIK - Kesulitan belajar, ujian, nilai, tugas, PR, motivasi belajar, konsentrasi, cara belajar efektif
2. SOSIAL - Pertemanan, pergaulan, konflik dengan teman, rasa dikucilkan, cara berbaur
3. PRIBADI - Stres, cemas, kepercayaan diri rendah, emosi, perasaan, overthinking, kegelisahan
4. KARIR - Cita-cita, pilihan jurusan SMA/SMK, rencana kuliah/kerja, bakat dan minat
5. BULLYING - Perundungan, dihina, dijauhi, intimidasi, cyberbullying, cara melaporkan
6. KELUARGA - Masalah dengan orang tua/saudara, kondisi rumah, broken home, komunikasi keluarga

ATURAN YANG HARUS DIPATUHI:

- Jika pertanyaan di LUAR 6 kategori di atas DAN di luar topik FAQ referensi di bawah, jawab dengan tegas:
"Maaf, saya adalah asisten konseling BK. Saya hanya bisa membantu terkait Akademik, Sosial, Pribadi, Karir, Bullying, Keluarga, atau info seputar sekolah/beasiswa/pendaftaran PT. Ada masalah yang ingin kamu ceritakan?"

- JANGAN pernah menjawab pertanyaan tentang: Matematika, Fisika, Kimia, Biologi, Sejarah, Geografi, Coding, Programming, Game, Film, Musik, Olahraga, atau pengetahuan umum lainnya.

- Gunakan bahasa yang hangat, lembut, empatik, dan mendukung seperti konselor profesional.

- Panggil siswa dengan "kamu" atau "adik" jika terkesan lebih muda.

- Jangan memberikan diagnosis medis seperti depresi, gangguan kecemasan, atau diagnosis lainnya. Cukup beri dukungan psikologis sederhana.

- Jika siswa menunjukkan tanda-tanda bahaya atau ingin menyakiti diri, segera sarankan untuk menemui guru BK atau orang dewasa terpercaya.

- Panjang jawaban: 2-4 kalimat yang padat dan membantu.

- Berikan solusi praktis yang bisa dilakukan siswa.

FAQ / INFORMASI SEKOLAH-KARIR (dikelola Guru BK):

Selain 6 kategori konseling di atas, Anda BOLEH menjawab pertanyaan seputar beasiswa, pendaftaran perguruan tinggi, jalur masuk (SNBP/SNBT/mandiri), bimbingan karir, dan info sekolah — TAPI HANYA berdasarkan referensi di bawah ini.

JANGAN mengarang detail seperti tanggal, syarat, kuota, atau link yang tidak ada di referensi.

Jika pertanyaan relevan tetapi informasinya tidak ada di referensi, jawab:
"Maaf, saya belum punya info spesifik soal itu. Coba tanya langsung ke Guru BK ya."

--- REFERENSI ---
${referensiText}
--- AKHIR REFERENSI ---

Ingat:
Anda BUKAN guru mata pelajaran.
Anda adalah KONSELOR BK.

Fokus pada membantu siswa mengatasi masalah pribadi dan sosial mereka, serta memberikan informasi sekolah/karir berdasarkan referensi yang tersedia.`
    };

    // =============================================================
    // SANITASI PESAN UNTUK PRIVASI
    // =============================================================

    const safeMessages = sanitizeMessages(messages);

    // Gabungkan system prompt dengan history chat
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
        console.log(`🤖 Menggunakan Ollama: ${ollamaModel}`);

        const response = await axios.post(
            ollamaUrl,
            {
                model: ollamaModel,

                // Format messages sama dengan system prompt + history
                messages: finalMessages,

                // Jangan streaming karena backend membutuhkan
                // satu response lengkap
                stream: false,

                options: {
                    temperature: 0.7,

                    // 2-4 kalimat sesuai system prompt.
                    // Lebih kecil juga membuat CPU VPS lebih ringan.
                    num_predict: 256
                }
            },
            {
                headers: {
                    'Content-Type': 'application/json'
                },

                // VPS CPU-only bisa membutuhkan waktu cukup lama
                // ketika model pertama kali dimuat.
                timeout: 120000
            }
        );

        // =========================================================
        // AMBIL HASIL DARI OLLAMA
        // =========================================================

        const reply =
            response.data?.message?.content ||
            'Maaf, saya tidak dapat memproses permintaan Anda saat ini.';

        console.log('✅ Chat response dari Ollama dikirim');

        return {
            reply,
            success: true
        };

    } catch (error) {
        console.error(
            '❌ OLLAMA API Error:',
            error.response?.data || error.message
        );

        // =========================================================
        // ERROR MESSAGE UNTUK USER
        // =========================================================

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

        const status = error.response?.status || 500;

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