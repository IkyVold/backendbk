// services/aiChatService.js
// Endpoint AI chatbot (GROQ) — logika disalin dari server.js, tidak diubah.
const axios = require('axios');
const informasiModel = require('../models/informasiModel');
const HttpError = require('../utils/HttpError');
const { sanitizeMessages } = require('../utils/sanitize');

async function chatWithAI(messages) {
    if (!messages || !Array.isArray(messages)) {
        // Bentuk error sama seperti response lama: { error: { message } }
        const err = new HttpError(400, 'Format pesan tidak valid');
        err.payload = { error: { message: 'Format pesan tidak valid' } };
        throw err;
    }

    console.log('📨 Chat request received');

    // Ambil pesan terakhir user
    const lastUserMessage = messages.filter(m => m.role === 'user').pop();
    if (lastUserMessage) {
        console.log('📝 Chat request diterima (isi disembunyikan)');
    }

    // Ambil knowledge base FAQ yang dikelola Guru BK (beasiswa, PT, karir, dll)
    let referensiText = '(Belum ada informasi tambahan dari Guru BK)';
    try {
        const infoRows = await informasiModel.listForChatbot();
        if (infoRows.length > 0) {
            referensiText = infoRows
                .map(r => `### ${r.judul} (${r.kategori})\n${r.isi}`)
                .join('\n\n');
        }
    } catch (e) {
        console.warn('Gagal ambil informasi_bk untuk konteks chatbot:', e.message);
    }

    // =============================================================
    // SYSTEM PROMPT - INI SATU-SATUNYA YANG MENGONTROL AI
    // Llama/GROQ akan memahami instruksi ini secara alami
    // TANPA PERLU DATA DUMMY ATAU KEYWORD BUATAN
    // =============================================================
    const counselingSystemPrompt = {
        role: 'system',
        content: `Anda adalah konselor BK profesional untuk siswa SMP/SMA.

**BATASAN KETAT - HANYA 6 KATEGORI KONSELING SEKOLAH INI:**
1. AKADEMIK - Kesulitan belajar, ujian, nilai, tugas, PR, motivasi belajar, konsentrasi, cara belajar efektif
2. SOSIAL - Pertemanan, pergaulan, konflik dengan teman, rasa dikucilkan, cara berbaur
3. PRIBADI - Stres, cemas, kepercayaan diri rendah, emosi, perasaan, overthinking, kegelisahan
4. KARIR - Cita-cita, pilihan jurusan SMA/SMK, rencana kuliah/kerja, bakat dan minat
5. BULLYING - Perundungan, dihina, dijauhi, intimidasi, cyberbullying, cara melaporkan
6. KELUARGA - Masalah dengan orang tua/saudara, kondisi rumah, broken home, komunikasi keluarga

**ATURAN YANG HARUS DIPATUHI:**
- Jika pertanyaan di LUAR 6 kategori di atas DAN di luar topik FAQ referensi di bawah, jawab dengan tegas:
  "Maaf, saya adalah asisten konseling BK. Saya hanya bisa membantu terkait Akademik, Sosial, Pribadi, Karir, Bullying, Keluarga, atau info seputar sekolah/beasiswa/pendaftaran PT. Ada masalah yang ingin kamu ceritakan?"
- JANGAN pernah menjawab pertanyaan tentang: Matematika, Fisika, Kimia, Biologi, Sejarah, Geografi, Coding, Programming, Game, Film, Musik, Olahraga, atau pengetahuan umum lainnya
- Gunakan bahasa yang hangat, lembut, empatik, dan mendukung seperti konselor profesional
- Panggil siswa dengan "kamu" atau "adik" (jika terkesan lebih muda)
- Jangan memberikan diagnosis medis (depresi, gangguan kecemasan, dll) - cukup beri dukungan psikologis sederhana
- Jika siswa menunjukkan tanda-tanda bahaya (ingin menyakiti diri), segera sarankan untuk menemui guru BK atau orang dewasa terpercaya
- Panjang jawaban: 2-4 kalimat yang padat dan membantu
- Beri solusi praktis yang bisa dilakukan siswa

**FAQ / INFORMASI SEKOLAH-KARIR (dikelola Guru BK):**
Selain 6 kategori konseling di atas, Anda BOLEH menjawab pertanyaan seputar beasiswa, pendaftaran perguruan tinggi, jalur masuk (SNBP/SNBT/mandiri), bimbingan karir, dan info sekolah — TAPI HANYA berdasarkan referensi di bawah ini. JANGAN mengarang detail (tanggal, syarat, kuota, link) yang tidak ada di referensi. Jika pertanyaan relevan tapi infonya tidak ada di referensi, jawab jujur: "Maaf, saya belum punya info spesifik soal itu. Coba tanya langsung ke Guru BK ya."

--- REFERENSI ---
${referensiText}
--- AKHIR REFERENSI ---

Ingat: Anda BUKAN guru mata pelajaran. Anda adalah KONSELOR BK. Fokus pada membantu siswa mengatasi masalah pribadi dan sosial mereka, plus info sekolah/karir dari referensi di atas.`
    };

    // Filter privasi pada pesan
    const safeMessages = sanitizeMessages(messages);

    // Gabungkan system prompt dengan history chat
    const finalMessages = [counselingSystemPrompt, ...safeMessages];

    // Panggil GROQ API
    try {
        const response = await axios.post(
            'https://api.groq.com/openai/v1/chat/completions',
            {
                model: process.env.GROQ_MODEL || 'llama-3.1-8b-instant',
                messages: finalMessages,
                max_tokens: 1024,
                temperature: 0.7
            },
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${process.env.GROQ_API_KEY}`
                },
                timeout: 30000
            }
        );

        const reply = response.data.choices[0]?.message?.content || 'Maaf, saya tidak dapat memproses permintaan Anda saat ini.';

        console.log('✅ Chat response dikirim');

        return { reply, success: true };
    } catch (error) {
        console.error('GROQ API Error:', error.response?.data || error.message);

        // Kirim error yang ramah untuk user (bentuk sama seperti handler lama)
        let errorMessage = 'Maaf, terjadi kesalahan pada server. Silakan coba lagi nanti.';

        if (error.response?.status === 401) {
            errorMessage = 'Maaf, layanan AI sedang tidak tersedia. Silakan coba lagi nanti.';
        } else if (error.response?.status === 429) {
            errorMessage = 'Maaf, terlalu banyak permintaan. Silakan tunggu sebentar.';
        } else if (error.code === 'ECONNABORTED') {
            errorMessage = 'Maaf, koneksi timeout. Silakan coba lagi.';
        }

        const status = error.response?.status || 500;
        const err = new HttpError(status, errorMessage);
        err.payload = {
            error: {
                message: errorMessage,
                status
            }
        };
        throw err;
    }
}

module.exports = { chatWithAI };
