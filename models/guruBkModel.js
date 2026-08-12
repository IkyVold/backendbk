// models/guruBkModel.js
const pool = require('../database');

async function ensureTable() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS guru_bk (
      id INT AUTO_INCREMENT PRIMARY KEY,
      username VARCHAR(50) NOT NULL UNIQUE,
      password VARCHAR(255) NOT NULL,
      nama VARCHAR(100) NOT NULL,
      spesialisasi VARCHAR(100) NOT NULL DEFAULT 'Guru BK',
      npsn VARCHAR(30) NULL,
      alamat VARCHAR(150) NULL,
      avatar VARCHAR(10) NULL,
      is_active TINYINT(1) NOT NULL DEFAULT 1,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  `);
}


async function ensureFotoColumn() {
  try {
    await pool.query("ALTER TABLE guru_bk ADD COLUMN foto_profile VARCHAR(255) NULL AFTER avatar");
  } catch (err) {
    if (err.code !== 'ER_DUP_FIELDNAME') {
      console.error('❌ Error migrasi foto_profile guru_bk:', err.message);
    }
  }
}

async function countAll() {
  const [[{ cnt }]] = await pool.query('SELECT COUNT(*) AS cnt FROM guru_bk');
  return cnt;
}

async function insert({ username, password, nama, spesialisasi, npsn, alamat, avatar }) {
  const [result] = await pool.query(
    `INSERT INTO guru_bk (username, password, nama, spesialisasi, npsn, alamat, avatar)
     VALUES (?, MD5(?), ?, ?, ?, ?, ?)`,
    [username, password, nama, spesialisasi || 'Guru BK', npsn || null, alamat || null, avatar || null]
  );
  return result;
}

async function updateById(id, { username, password, nama, spesialisasi, npsn, alamat, avatar, is_active }) {
  const sets = [];
  const vals = [];
  if (username !== undefined) { sets.push('username = ?'); vals.push(username); }
  if (password) { sets.push('password = MD5(?)'); vals.push(password); }
  if (nama !== undefined) { sets.push('nama = ?'); vals.push(nama); }
  if (spesialisasi !== undefined) { sets.push('spesialisasi = ?'); vals.push(spesialisasi); }
  if (npsn !== undefined) { sets.push('npsn = ?'); vals.push(npsn); }
  if (alamat !== undefined) { sets.push('alamat = ?'); vals.push(alamat); }
  if (avatar !== undefined) { sets.push('avatar = ?'); vals.push(avatar); }
  if (is_active !== undefined) { sets.push('is_active = ?'); vals.push(is_active ? 1 : 0); }
  if (sets.length === 0) return { affectedRows: 0 };
  vals.push(id);
  const [result] = await pool.query(`UPDATE guru_bk SET ${sets.join(', ')} WHERE id = ?`, vals);
  return result;
}

async function softDelete(id) {
  const [result] = await pool.query('UPDATE guru_bk SET is_active = 0 WHERE id = ?', [id]);
  return result;
}

async function hardDelete(id) {
  const [result] = await pool.query('DELETE FROM guru_bk WHERE id = ?', [id]);
  return result;
}

async function listAll() {
  const [rows] = await pool.query(
    `SELECT id, username, nama, spesialisasi, npsn, alamat, avatar, foto_profile, is_active, created_at
     FROM guru_bk ORDER BY nama ASC`
  );
  return rows;
}

/** Daftar aktif untuk halaman Pilih Guru. Username ikut untuk notifikasi andal. */
async function listActivePublic() {
  const [rows] = await pool.query(
    `SELECT id, username, nama, spesialisasi, npsn, alamat, avatar, foto_profile
     FROM guru_bk WHERE is_active = 1 ORDER BY nama ASC`
  );
  return rows;
}

async function findByUsernamePassword(username, password) {
  const [rows] = await pool.query(
    `SELECT id, username, nama, spesialisasi, npsn, alamat, avatar, foto_profile
     FROM guru_bk
     WHERE username = ? AND password = MD5(?) AND is_active = 1`,
    [username, password]
  );
  return rows;
}

async function findByUsername(username) {
  const [rows] = await pool.query(
    'SELECT id, username, nama, avatar, foto_profile, is_active FROM guru_bk WHERE username = ?',
    [username]
  );
  return rows;
}

/**
 * Cari guru aktif berdasarkan nama atau username.
 * Matching: exact → trim → case-insensitive → username.
 */
async function findByNama(nama) {
  if (!nama || !String(nama).trim()) return [];
  const key = String(nama).trim();

  // 1) Exact
  let [rows] = await pool.query(
    `SELECT id, username, nama, avatar, foto_profile, is_active
     FROM guru_bk WHERE nama = ? AND is_active = 1 LIMIT 1`,
    [key]
  );
  if (rows.length) return rows;

  // 2) Case-insensitive
  [rows] = await pool.query(
    `SELECT id, username, nama, avatar, foto_profile, is_active
     FROM guru_bk WHERE LOWER(TRIM(nama)) = LOWER(?) AND is_active = 1 LIMIT 1`,
    [key]
  );
  if (rows.length) return rows;

  // 3) Username (kalau form kirim username)
  [rows] = await pool.query(
    `SELECT id, username, nama, avatar, foto_profile, is_active
     FROM guru_bk WHERE username = ? AND is_active = 1 LIMIT 1`,
    [key]
  );
  return rows;
}

async function findById(id) {
  const [rows] = await pool.query(
    `SELECT id, username, nama, spesialisasi, npsn, alamat, avatar, foto_profile, is_active
     FROM guru_bk WHERE id = ?`,
    [id]
  );
  return rows;
}


async function updateFotoProfile(id, fotoPath) {
  const [result] = await pool.query(
    'UPDATE guru_bk SET foto_profile = ? WHERE id = ?',
    [fotoPath, id]
  );
  return result;
}

async function clearFotoProfile(id) {
  const [result] = await pool.query(
    'UPDATE guru_bk SET foto_profile = NULL WHERE id = ?',
    [id]
  );
  return result;
}

module.exports = {
  ensureTable,
  ensureFotoColumn,
  countAll,
  insert,
  updateById,
  softDelete,
  hardDelete,
  listAll,
  listActivePublic,
  findByUsernamePassword,
  findByUsername,
  findByNama,
  findById,
  updateFotoProfile,
  clearFotoProfile,
};
