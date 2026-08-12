// models/chatModel.js
const pool = require('../database');

async function ensureTable() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS chat_messages (
      id INT AUTO_INCREMENT PRIMARY KEY,
      session_id VARCHAR(150) NOT NULL,
      sender_id VARCHAR(50) NOT NULL,
      sender_name VARCHAR(100),
      sender_type ENUM('siswa','guru') NOT NULL,
      message TEXT NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      INDEX (session_id)
    )
  `);
}

async function countAll() {
  const [[{ cnt }]] = await pool.query('SELECT COUNT(*) AS cnt FROM chat_messages');
  return cnt;
}

async function insertMessage({ sessionId, senderId, senderName, senderType, message, createdAt }) {
  if (createdAt !== undefined) {
    const [result] = await pool.query(
      `INSERT INTO chat_messages (session_id, sender_id, sender_name, sender_type, message, created_at)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [sessionId, senderId, senderName, senderType, message, createdAt]
    );
    return result;
  }
  const [result] = await pool.query(
    `INSERT INTO chat_messages (session_id, sender_id, sender_name, sender_type, message)
     VALUES (?, ?, ?, ?, ?)`,
    [sessionId, senderId, senderName, senderType, message]
  );
  return result;
}

async function listBySessionId(sessionId) {
  const [rows] = await pool.query(
    `SELECT cm.id, cm.sender_id, cm.sender_name, cm.sender_type, cm.message, cm.created_at,
            s.foto_profile
     FROM chat_messages cm
     LEFT JOIN siswa s ON cm.sender_type = 'siswa' AND s.nis = cm.sender_id
     WHERE cm.session_id = ?
     ORDER BY cm.id ASC`,
    [sessionId]
  );
  return rows;
}

module.exports = {
  ensureTable,
  countAll,
  insertMessage,
  listBySessionId,
};
