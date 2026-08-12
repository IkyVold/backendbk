// models/kepsekModel.js
const pool = require('../database');

async function ensureTable() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS kepala_sekolah (
      id INT AUTO_INCREMENT PRIMARY KEY,
      username VARCHAR(50) NOT NULL UNIQUE,
      password VARCHAR(255) NOT NULL,
      nama VARCHAR(100) NOT NULL,
      nip VARCHAR(30) NULL,
      sekolah VARCHAR(150) NULL,
      jabatan VARCHAR(100) NOT NULL DEFAULT 'Kepala Sekolah',
      avatar VARCHAR(10) NULL,
      is_active TINYINT(1) NOT NULL DEFAULT 1,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  `);
}

async function countAll() {
  const [[{ cnt }]] = await pool.query('SELECT COUNT(*) AS cnt FROM kepala_sekolah');
  return cnt;
}

async function insert({ username, password, nama, nip, sekolah, jabatan, avatar }) {
  const [result] = await pool.query(
    `INSERT INTO kepala_sekolah (username, password, nama, nip, sekolah, jabatan, avatar)
     VALUES (?, MD5(?), ?, ?, ?, ?, ?)`,
    [username, password, nama, nip || null, sekolah || null, jabatan || 'Kepala Sekolah', avatar || null]
  );
  return result;
}

async function updateById(id, { username, password, nama, nip, sekolah, jabatan, avatar, is_active }) {
  const sets = [];
  const vals = [];
  if (username !== undefined) { sets.push('username = ?'); vals.push(username); }
  if (password) { sets.push('password = MD5(?)'); vals.push(password); }
  if (nama !== undefined) { sets.push('nama = ?'); vals.push(nama); }
  if (nip !== undefined) { sets.push('nip = ?'); vals.push(nip); }
  if (sekolah !== undefined) { sets.push('sekolah = ?'); vals.push(sekolah); }
  if (jabatan !== undefined) { sets.push('jabatan = ?'); vals.push(jabatan); }
  if (avatar !== undefined) { sets.push('avatar = ?'); vals.push(avatar); }
  if (is_active !== undefined) { sets.push('is_active = ?'); vals.push(is_active ? 1 : 0); }
  if (sets.length === 0) return { affectedRows: 0 };
  vals.push(id);
  const [result] = await pool.query(`UPDATE kepala_sekolah SET ${sets.join(', ')} WHERE id = ?`, vals);
  return result;
}

async function softDelete(id) {
  const [result] = await pool.query('UPDATE kepala_sekolah SET is_active = 0 WHERE id = ?', [id]);
  return result;
}

async function hardDelete(id) {
  const [result] = await pool.query('DELETE FROM kepala_sekolah WHERE id = ?', [id]);
  return result;
}

async function listAll() {
  const [rows] = await pool.query(
    `SELECT id, username, nama, nip, sekolah, jabatan, avatar, is_active, created_at
     FROM kepala_sekolah ORDER BY nama ASC`
  );
  return rows;
}

async function findByUsernamePassword(username, password) {
  const [rows] = await pool.query(
    `SELECT id, username, nama, nip, sekolah, jabatan, avatar
     FROM kepala_sekolah
     WHERE username = ? AND password = MD5(?) AND is_active = 1`,
    [username, password]
  );
  return rows;
}

async function findByUsername(username) {
  const [rows] = await pool.query('SELECT id FROM kepala_sekolah WHERE username = ?', [username]);
  return rows;
}

module.exports = {
  ensureTable,
  countAll,
  insert,
  updateById,
  softDelete,
  hardDelete,
  listAll,
  findByUsernamePassword,
  findByUsername,
};
