// services/chatService.js
// Penyimpanan riwayat chat real-time (tabel chat_messages) + migrasi JSON lama.
// Perilaku disalin dari server.js asli — tidak diubah.
const fs = require('fs');
const path = require('path');
const { sanitizeText } = require('../utils/sanitize');
const chatModel = require('../models/chatModel');
const siswaModel = require('../models/siswaModel');

const CHAT_HISTORY_FILE = path.join(__dirname, '..', 'chat_history.json');

async function ensureChatMessagesTable() {
  try {
    await chatModel.ensureTable();
    console.log('✅ Tabel chat_messages siap');
  } catch (err) {
    console.error('❌ Error membuat tabel chat_messages:', err.message);
  }
}

// Migrasi sekali jalan: kalau chat_history.json (versi lama) masih ada dan
// tabel chat_messages masih kosong, pindahkan isinya ke database supaya
// riwayat chat lama tidak hilang. File lama di-rename jadi .migrated setelahnya.
async function migrateChatHistoryJsonIfNeeded() {
  try {
    if (!fs.existsSync(CHAT_HISTORY_FILE)) return;

    const cnt = await chatModel.countAll();
    if (cnt > 0) return; // sudah ada data di DB, jangan timpa

    const raw = fs.readFileSync(CHAT_HISTORY_FILE, 'utf8');
    const historyBySession = JSON.parse(raw);

    let total = 0;
    for (const sessionId of Object.keys(historyBySession)) {
      const messages = historyBySession[sessionId] || [];
      for (const msg of messages) {
        await chatModel.insertMessage({
          sessionId,
          senderId: String(msg.senderId ?? 'unknown'),
          senderName: msg.senderName ?? null,
          senderType: (msg.senderType === 'guru' ? 'guru' : 'siswa'),
          message: msg.message ?? '',
          createdAt: msg.timestamp ? new Date(msg.timestamp) : new Date(),
        });
        total++;
      }
    }

    fs.renameSync(CHAT_HISTORY_FILE, CHAT_HISTORY_FILE + '.migrated');
    console.log(`✅ Migrasi chat_history.json selesai — ${total} pesan dipindahkan ke database`);
  } catch (err) {
    console.error('❌ Error migrasi chat_history.json ke database:', err.message);
  }
}


async function ensureChatSessionTable() {
  const pool = require('../database');
  await pool.query(`
    CREATE TABLE IF NOT EXISTS chat_session (
      id VARCHAR(64) PRIMARY KEY,
      konseling_id INT NOT NULL UNIQUE,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      closed_at TIMESTAMP NULL DEFAULT NULL,
      INDEX idx_chat_session_konseling (konseling_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  `);
}

async function ensureChatSession(sessionId, konselingId) {
  const pool = require('../database');
  await pool.query(
    `INSERT INTO chat_session (id, konseling_id)
     VALUES (?, ?)
     ON DUPLICATE KEY UPDATE last_activity_at = CURRENT_TIMESTAMP`,
    [sessionId, konselingId]
  );
}

async function initChatStorage() {
  await ensureChatMessagesTable();
  await ensureChatSessionTable();
  await migrateChatHistoryJsonIfNeeded();
}

async function getChatHistoryFromDb(sessionId) {
  const rows = await chatModel.listBySessionId(sessionId);
  return rows.map(r => ({
    id: r.id,
    senderId: r.sender_id,
    senderName: r.sender_name,
    senderType: r.sender_type,
    senderFoto: r.foto_profile || null,
    message: r.message,
    timestamp: r.created_at
  }));
}

/**
 * Simpan pesan chat + ambil foto pengirim (jika siswa).
 * Return messageData siap di-emit lewat Socket.IO (sama struktur seperti server.js lama).
 */
async function saveChatMessage({ sessionId, message, senderId, senderName, senderType }) {
  const sanitizedMessage = sanitizeText(message);
  const dbSenderType = senderType === 'guru' ? 'guru' : 'siswa';

  console.log(`📨 Message in session (isi disembunyikan) from role=${senderType}`);

  const result = await chatModel.insertMessage({
    sessionId,
    senderId: String(senderId),
    senderName: senderName || null,
    senderType: dbSenderType,
    message: sanitizedMessage,
  });

  // Ambil foto profil pengirim (kalau siswa) supaya bisa ditampilkan di bubble chat
  let senderFoto = null;
  if (dbSenderType === 'siswa') {
    const siswaRows = await siswaModel.findFotoByNis(String(senderId));
    if (siswaRows.length > 0) senderFoto = siswaRows[0].foto_profile;
  }

  return {
    id: result.insertId,
    senderId,
    senderName,
    senderType: dbSenderType,
    senderFoto,
    message: sanitizedMessage,
    timestamp: new Date().toISOString()
  };
}

module.exports = {
  initChatStorage,
  getChatHistoryFromDb,
  saveChatMessage,
  ensureChatSession,
};
