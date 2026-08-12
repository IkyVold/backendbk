// socket/registerChatSocket.js
// Handler Socket.IO chat real-time + join room notifikasi siswa.
// Logika disalin dari server.js asli — event names, payload, dan alur tidak diubah.
const chatService = require('../services/chatService');
const { verifyToken, extractTokenFromSocket } = require('../middleware/auth');
const { parseKonselingIdFromSession } = require('../utils/chatSession');
const konselingModel = require('../models/konselingModel');

/**
 * Daftarkan semua handler chat pada instance Socket.IO.
 * @param {import('socket.io').Server} io
 * @returns {{ activeSessions: Map }} map sesi aktif (dipakai /health)
 */
function registerChatSocket(io) {
    const activeSessions = new Map();

    // Init tabel + migrasi JSON (sama seperti initChatStorage() di server.js lama)
    chatService.initChatStorage();

    // Wajibkan JWT di handshake (auth.token atau query.token)
    io.use((socket, next) => {
        try {
            const token =
                extractTokenFromSocket(socket) ||
                (socket.handshake.headers?.authorization || '').replace(/^Bearer\s+/i, '');
            if (!token) {
                return next(new Error('Autentikasi Socket.IO diperlukan'));
            }
            socket.user = verifyToken(token);
            next();
        } catch (err) {
            next(new Error('Token Socket.IO tidak valid'));
        }
    });

    io.on('connection', (socket) => {
        console.log('✅ User connected:', socket.id);

        let currentSessionId = null;
        let currentUserId = null;
        let currentUserType = null;

        // Join room notifikasi pribadi siswa (dipakai untuk badge & panel riwayat notifikasi jadwal)
        socket.on('join-siswa-notif', () => {
            try {
                // NIS hanya dari JWT — jangan terima dari client
                if (!socket.user || socket.user.role !== 'siswa' || !socket.user.nis) {
                    return;
                }
                const nis = String(socket.user.nis);
                socket.join(`siswa-notif-${nis}`);
                console.log(`📌 Siswa NIS ${nis} join room notifikasi (socket: ${socket.id})`);
            } catch (error) {
                console.error('Error in join-siswa-notif:', error);
            }
        });

        // Join room notifikasi Guru BK
        socket.on('join-guru-notif', () => {
            try {
                // Hanya guru — room dari JWT username, bukan client
                if (!socket.user || socket.user.role !== 'guru' || !socket.user.username) {
                    return;
                }
                const username = String(socket.user.username);
                socket.join(`guru-notif-${username}`);
                console.log(`📌 Guru ${username} join room notifikasi (socket: ${socket.id})`);
            } catch (error) {
                console.error('Error in join-guru-notif:', error);
            }
        });

        // Join chat room
        socket.on('join-chat', async (data) => {
            try {
                const { userId, userType, sessionId, userName } = data;

                if (!sessionId) {
                    socket.emit('error', { message: 'sessionId wajib' });
                    return;
                }

                if (!socket.user) {
                    socket.emit('error', { message: 'Autentikasi diperlukan' });
                    return;
                }

                // Session harus format konseling_<id>
                const konselingId = parseKonselingIdFromSession(sessionId);
                if (!konselingId) {
                    socket.emit('error', {
                        message: 'Format sesi chat tidak valid. Gunakan sesi berbasis konseling_id.',
                    });
                    return;
                }

                // Otorisasi: user harus pemilik / guru penanggung jawab, jenis Daring
                const rows = await konselingModel.findForStatus(konselingId);
                if (!rows.length) {
                    socket.emit('error', { message: 'Data konseling tidak ditemukan' });
                    return;
                }
                const k = rows[0];

                if (String(k.jenis) !== 'Daring') {
                    socket.emit('error', { message: 'Chat hanya untuk konseling daring' });
                    return;
                }
                if (k.status === 'Dibatalkan') {
                    socket.emit('error', { message: 'Konseling ini sudah dibatalkan' });
                    return;
                }

                if (socket.user.role === 'siswa') {
                    const ok =
                        String(k.nis) === String(socket.user.nis) ||
                        Number(k.siswa_id) === Number(socket.user.id);
                    if (!ok) {
                        socket.emit('error', { message: 'Anda tidak berhak masuk chat konseling ini' });
                        return;
                    }
                } else if (socket.user.role === 'guru') {
                    const byId =
                      k.guru_id != null &&
                      socket.user.id != null &&
                      Number(k.guru_id) === Number(socket.user.id);
                    const byNama =
                      String(k.guru_bk || '').trim() === String(socket.user.nama || '').trim();
                    if (!byId && !byNama) {
                        socket.emit('error', { message: 'Anda tidak berhak masuk chat konseling ini' });
                        return;
                    }
                } else if (socket.user.role !== 'admin') {
                    socket.emit('error', { message: 'Role tidak diizinkan untuk chat konseling' });
                    return;
                }

                // Catat session registry (idempotent)
                try {
                    await chatService.ensureChatSession(sessionId, konselingId);
                } catch (e) {
                    console.warn('ensureChatSession:', e.message);
                }

                // Identitas dari JWT, bukan payload client
                const safeUserType = socket.user.role === 'guru' ? 'guru' : 'siswa';
                const safeUserId =
                    safeUserType === 'siswa'
                        ? String(socket.user.nis || socket.user.id)
                        : String(socket.user.username || socket.user.id);
                const safeUserName = String(socket.user.nama || safeUserId);

                currentSessionId = sessionId;
                currentUserId = safeUserId;
                currentUserType = safeUserType;

                // Join room
                socket.join(sessionId);
                console.log(`📌 ${safeUserName} (${safeUserType}) joined room: ${sessionId}`);

                // Store session info
                if (!activeSessions.has(sessionId)) {
                    activeSessions.set(sessionId, {
                        siswaId: safeUserType === 'siswa' ? safeUserId : null,
                        guruId: safeUserType === 'guru' ? safeUserId : null,
                        siswaName: safeUserType === 'siswa' ? safeUserName : null,
                        guruName: safeUserType === 'guru' ? safeUserName : null,
                        siswaSocket: safeUserType === 'siswa' ? socket.id : null,
                        guruSocket: safeUserType === 'guru' ? socket.id : null
                    });
                } else {
                    const session = activeSessions.get(sessionId);
                    if (safeUserType === 'siswa') {
                        session.siswaId = safeUserId;
                        session.siswaName = safeUserName;
                        session.siswaSocket = socket.id;
                    } else {
                        session.guruId = safeUserId;
                        session.guruName = safeUserName;
                        session.guruSocket = socket.id;
                    }
                    activeSessions.set(sessionId, session);
                }

                // Send history to the user who just joined (dari database)
                const history = await chatService.getChatHistoryFromDb(sessionId);
                if (history.length > 0) {
                    console.log(`📚 Sending ${history.length} messages to ${safeUserName}`);
                    socket.emit('chat-history', history);
                }

                // Notify others in the room
                socket.to(sessionId).emit('user-joined', {
                    userId: safeUserId,
                    userName: safeUserName,
                    userType: safeUserType,
                    message: `${safeUserName} telah bergabung dalam konseling.`
                });

            } catch (error) {
                console.error('Error in join-chat:', error);
            }
        });

        // Handle incoming chat message
        socket.on('chat-message', async (data) => {
            try {
                const { sessionId, message } = data || {};

                if (!sessionId || !message) {
                    socket.emit('error', { message: 'Data pesan tidak valid' });
                    return;
                }
                if (!socket.user) {
                    socket.emit('error', { message: 'Autentikasi diperlukan' });
                    return;
                }
                // Harus sudah join room ini
                if (currentSessionId !== sessionId || !socket.rooms.has(sessionId)) {
                    socket.emit('error', { message: 'Anda belum bergabung ke sesi chat ini' });
                    return;
                }

                // Identitas 100% dari JWT
                const senderType = socket.user.role === 'guru' ? 'guru' : 'siswa';
                const senderId =
                    senderType === 'siswa'
                        ? String(socket.user.nis || socket.user.id)
                        : String(socket.user.username || socket.user.id);
                const senderName = String(socket.user.nama || senderId);

                const messageData = await chatService.saveChatMessage({
                    sessionId,
                    message,
                    senderId,
                    senderName,
                    senderType,
                });

                io.to(sessionId).emit('new-message', messageData);

            } catch (error) {
                console.error('Error in chat-message:', error);
                socket.emit('error', { message: 'Gagal mengirim pesan' });
            }
        });

        // Handle typing indicator
        socket.on('typing', (data) => {
            try {
                const { sessionId, isTyping, userName } = data;
                if (sessionId) {
                    socket.to(sessionId).emit('user-typing', {
                        userId: currentUserId,
                        userName: userName,
                        isTyping: isTyping
                    });
                }
            } catch (error) {
                console.error('Error in typing:', error);
            }
        });

        // Handle disconnect
        socket.on('disconnect', (reason) => {
            console.log(`❌ User disconnected: ${socket.id}, reason: ${reason}`);

            if (currentSessionId && activeSessions.has(currentSessionId)) {
                const session = activeSessions.get(currentSessionId);

                if (session.siswaSocket === socket.id) {
                    session.siswaSocket = null;
                    session.siswaOnline = false;
                } else if (session.guruSocket === socket.id) {
                    session.guruSocket = null;
                    session.guruOnline = false;
                }

                const otherUser = session.siswaSocket || session.guruSocket;
                if (otherUser) {
                    io.to(currentSessionId).emit('user-left', {
                        message: `${currentUserType === 'siswa' ? 'Siswa' : 'Guru'} telah meninggalkan chat`
                    });
                }

                if (!session.siswaSocket && !session.guruSocket) {
                    setTimeout(() => {
                        if (activeSessions.has(currentSessionId) &&
                            !activeSessions.get(currentSessionId).siswaSocket &&
                            !activeSessions.get(currentSessionId).guruSocket) {
                            activeSessions.delete(currentSessionId);
                            console.log(`🗑️ Session ${currentSessionId} removed`);
                        }
                    }, 30000);
                }
            }
        });

        socket.on('error', (error) => {
            console.error('Socket error:', error);
        });
    });

    return { activeSessions };
}

module.exports = { registerChatSocket };
