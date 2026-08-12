const express = require('express');
const cors = require('cors');
const cookieParser = require('cookie-parser');
const http = require('http');
const socketIo = require('socket.io');
const fs = require('fs');
const path = require('path');
// web-push bersifat opsional: kalau paketnya belum di-install (npm install belum
// dijalankan ulang setelah update), server tetap harus jalan normal — hanya fitur
// push notification yang nonaktif, bukan seluruh backend (termasuk Socket.IO chat).
let webpush = null;
try {
    webpush = require('web-push');
} catch (err) {
    console.warn('⚠️  Package "web-push" belum ter-install. Jalankan `npm install` di folder backend agar fitur push notification aktif.');
}
require('dotenv').config();

// Semua domain API sudah direfactor ke pola services/controllers/routes.
// Socket.IO chat: socket/registerChatSocket.js
const authRoutes = require('./routes/authRoutes');
const siswaRoutes = require('./routes/siswaRoutes');
const profileRoutes = require('./routes/profileRoutes');
const riwayatKelasRoutes = require('./routes/riwayatKelasRoutes');
const informasiRoutes = require('./routes/informasiRoutes');
const konselingRoutes = require('./routes/konselingRoutes');
const notifikasiRoutes = require('./routes/notifikasiRoutes');
const chatRoutes = require('./routes/chatRoutes');
const akunRoutes = require('./routes/akunRoutes');
const notifikasiDispatch = require('./services/notifikasiDispatch');
const { registerChatSocket } = require('./socket/registerChatSocket');
const { errorHandler } = require('./middleware/errorHandler');
const { csrfProtect } = require('./middleware/auth');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
    cors: {
        origin: [
            'http://127.0.0.1:5500',
            'http://localhost:5500',
            'http://localhost:3000',
            'http://localhost:8080',
            'http://localhost:5173',
            'http://127.0.0.1:5173',
            'http://157.10.161.170:5000',
            'http://157.10.161.170:8080'
        ],
        credentials: true,
        methods: ['GET', 'POST']
    },
    transports: ['websocket', 'polling']
});

// Socket.IO chat real-time + join-siswa-notif (logika di socket/registerChatSocket.js)
const { activeSessions } = registerChatSocket(io);

const PORT = process.env.PORT || 8080;

// ===============================
// WEB PUSH (VAPID) - notifikasi jadwal konseling
// ===============================
const VAPID_PUBLIC_KEY = process.env.VAPID_PUBLIC_KEY || '';
const VAPID_PRIVATE_KEY = process.env.VAPID_PRIVATE_KEY || '';
const VAPID_SUBJECT = process.env.VAPID_SUBJECT || 'mailto:admin@stopbullying.example';

if (webpush && VAPID_PUBLIC_KEY && VAPID_PRIVATE_KEY) {
    webpush.setVapidDetails(VAPID_SUBJECT, VAPID_PUBLIC_KEY, VAPID_PRIVATE_KEY);
    console.log('✅ Web Push (VAPID) siap digunakan');
} else if (!webpush) {
    // Peringatan sudah dicetak saat require gagal di atas
} else {
    console.warn('⚠️  VAPID_PUBLIC_KEY/VAPID_PRIVATE_KEY belum diatur — push notification dinonaktifkan. Jalankan: node scripts/generate-vapid-keys.js');
}

// Inject dependency realtime ke helper notifikasi (dipakai konselingService)
notifikasiDispatch.configure({
    io,
    webpush,
    VAPID_PUBLIC_KEY,
    VAPID_PRIVATE_KEY,
});

// ===============================
// MIDDLEWARE
// ===============================
app.use(cors({
    origin: [
        'http://127.0.0.1:5500',
        'http://localhost:5500',
        'http://localhost:3000',
        'http://localhost:8080',
        'http://localhost:5173',
        'http://127.0.0.1:5173',
        'http://157.10.161.170:5000',
        'http://157.10.161.170:8080'
    ],
    credentials: true
}));
app.use(cookieParser());
app.use(csrfProtect);
app.use(express.json({ limit: '10mb' }));

// Folder penyimpanan file upload (foto profil siswa) — disajikan statis
// supaya bisa diakses langsung lewat URL, mis. /uploads/siswa/xxxx.jpg
const UPLOADS_DIR = path.join(__dirname, 'uploads');
const FOTO_SISWA_DIR = path.join(UPLOADS_DIR, 'siswa');
if (!fs.existsSync(FOTO_SISWA_DIR)) {
    fs.mkdirSync(FOTO_SISWA_DIR, { recursive: true });
}
app.use('/uploads', express.static(UPLOADS_DIR));

// Endpoint /api/register dan /api/login ditangani modul auth yang sudah direfactor.
app.use('/api', authRoutes);
app.use('/api', siswaRoutes);
app.use('/api', profileRoutes);
app.use('/api', riwayatKelasRoutes);
app.use('/api', informasiRoutes);
app.use('/api', konselingRoutes);
app.use('/api', notifikasiRoutes);
app.use('/api', chatRoutes);
app.use('/api', akunRoutes);

// ===============================
// CHAT / SOCKET.IO / AI
// - Real-time: socket/registerChatSocket.js (registerChatSocket(io))
// - Storage: services/chatService.js
// - AI chatbot POST /api/chat: chatRoutes -> chatController -> aiChatService
// Perilaku event & payload tidak diubah (pure refactor).
// ===============================


// ===============================
// TEST ENDPOINT
// ===============================
app.get('/api/test', (req, res) => {
    res.json({
        status: 'OK',
        message: 'Server berjalan dengan baik',
        timestamp: new Date().toISOString(),
        socketConnected: true,
        aiModel: process.env.GROQ_MODEL || 'llama-3.1-8b-instant'
    });
});

// ===============================
// HEALTH CHECK
// ===============================
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        uptime: process.uptime(),
        timestamp: new Date().toISOString(),
        activeSessions: activeSessions.size
    });
});

// Semua domain API sudah di-mount di atas (auth, siswa, profile, riwayatKelas,
// informasi, konseling, notifikasi/push, chat). Socket.IO di registerChatSocket(io).

// Error handler terpusat: harus didaftarkan paling akhir, setelah semua route.
// Route yang masih pakai try/catch manual (belum dimigrasi) tidak terpengaruh;
// ini menangani error dari route baru yang pakai asyncHandler (semua route modul yang pakai asyncHandler).
app.use(errorHandler);

// ===============================
// START SERVER
// ===============================
server.listen(PORT, () => {
    console.log(`========================================`);
    console.log(`🚀 Server berjalan di http://localhost:${PORT}`);
    console.log(`🔌 Socket.IO server listening on port ${PORT}`);
    console.log(`🤖 GROQ API Key: ${process.env.GROQ_API_KEY ? '✅ Tersedia' : '❌ Tidak tersedia'}`);
    console.log(`📦 Model: ${process.env.GROQ_MODEL || 'llama-3.1-8b-instant'}`);
    console.log(`========================================`);
    console.log(`🎯 AI Chatbot dibatasi pada 6 kategori konseling:`);
    console.log(`   1. Akademik   2. Sosial   3. Pribadi`);
    console.log(`   4. Karir      5. Bullying  6. Keluarga`);
    console.log(`========================================`);
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down server...');
    // Pesan chat sudah langsung tersimpan ke database tiap kali dikirim,
    // jadi tidak perlu lagi menyimpan apapun secara manual di sini.
    server.close(() => {
        console.log('✅ Server closed');
        process.exit(0);
    });
});

process.on('uncaughtException', (error) => {
    console.error('Uncaught Exception:', error);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection:', reason);
});