// models/informasiModel.js
const pool = require('../database');

async function ensureTable() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS informasi_bk (
      id INT AUTO_INCREMENT PRIMARY KEY,
      judul VARCHAR(150) NOT NULL,
      kategori VARCHAR(50) NOT NULL,
      isi TEXT NOT NULL,
      guru_bk VARCHAR(100) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    )
  `);
}

async function listAll(kategori) {
  let sql = 'SELECT * FROM informasi_bk';
  const params = [];
  if (kategori) {
    sql += ' WHERE kategori = ?';
    params.push(kategori);
  }
  sql += ' ORDER BY updated_at DESC';
  const [rows] = await pool.query(sql, params);
  return rows;
}

async function insert({ judul, kategori, isi, guru_bk }) {
  const [result] = await pool.query(
    'INSERT INTO informasi_bk (judul, kategori, isi, guru_bk) VALUES (?, ?, ?, ?)',
    [judul, kategori, isi, guru_bk]
  );
  return result;
}

async function updateById(id, { judul, kategori, isi }) {
  const [result] = await pool.query(
    'UPDATE informasi_bk SET judul = ?, kategori = ?, isi = ? WHERE id = ?',
    [judul, kategori, isi, id]
  );
  return result;
}

async function deleteById(id) {
  const [result] = await pool.query('DELETE FROM informasi_bk WHERE id = ?', [id]);
  return result;
}

async function listForChatbot() {
  const [rows] = await pool.query(
    'SELECT judul, kategori, isi FROM informasi_bk ORDER BY updated_at DESC'
  );
  return rows;
}

module.exports = {
  ensureTable,
  listAll,
  insert,
  updateById,
  deleteById,
  listForChatbot,
};
