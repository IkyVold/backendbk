// models/adminModel.js
const pool = require('../database');

async function ensureTable() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS admin_master (
      id INT AUTO_INCREMENT PRIMARY KEY,
      username VARCHAR(50) NOT NULL UNIQUE,
      password VARCHAR(255) NOT NULL,
      nama VARCHAR(100) NOT NULL DEFAULT 'Admin',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  `);
}

async function countAll() {
  const [[{ cnt }]] = await pool.query('SELECT COUNT(*) AS cnt FROM admin_master');
  return cnt;
}

async function insert({ username, password, nama }) {
  const [result] = await pool.query(
    `INSERT INTO admin_master (username, password, nama) VALUES (?, MD5(?), ?)`,
    [username, password, nama || 'Admin']
  );
  return result;
}

async function findByUsernamePassword(username, password) {
  const [rows] = await pool.query(
    `SELECT id, username, nama FROM admin_master
     WHERE username = ? AND password = MD5(?)`,
    [username, password]
  );
  return rows;
}

module.exports = {
  ensureTable,
  countAll,
  insert,
  findByUsernamePassword,
};
