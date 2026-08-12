// models/siswaModel.js
// Akses data tabel `siswa` — pure query, tanpa logika bisnis.
const pool = require('../database');

async function findIdByNis(nis) {
  const [rows] = await pool.query('SELECT id FROM siswa WHERE nis = ?', [nis]);
  return rows;
}

async function findByNisAndPassword(nis, password) {
  const [rows] = await pool.query(
    'SELECT id, nis, nama, kelas, foto_profile FROM siswa WHERE nis = ? AND password = MD5(?)',
    [nis, password]
  );
  return rows;
}

async function insertSiswa({ nis, nama, kelas, jenis_kelamin, password }) {
  const [result] = await pool.query(
    'INSERT INTO siswa (nis, nama, kelas, jenis_kelamin, password) VALUES (?, ?, ?, ?, MD5(?))',
    [nis, nama, kelas, jenis_kelamin, password]
  );
  return result;
}

async function updateBasicByNis(nis, { nama, kelas, jenis_kelamin }) {
  const [result] = await pool.query(
    'UPDATE siswa SET nama = ?, kelas = ?, jenis_kelamin = COALESCE(?, jenis_kelamin) WHERE nis = ?',
    [nama, kelas, jenis_kelamin, nis]
  );
  return result;
}

async function listAllWithKelasAktif() {
  const [rows] = await pool.query(`
    SELECT
      s.nis,
      s.nama,
      s.kelas,
      s.jenis_kelamin,
      s.foto_profile,
      rk.tahun_ajaran,
      rk.status AS status_kelas
    FROM siswa s
    LEFT JOIN riwayat_kelas rk
      ON rk.nis = s.nis AND rk.status = 'aktif'
    ORDER BY s.nama ASC
  `);
  return rows;
}

async function findProfileByNis(nis) {
  const [rows] = await pool.query(
    `SELECT id, nis, nama, kelas, jenis_kelamin,
            DATE_FORMAT(tanggal_lahir, '%Y-%m-%d') as tanggal_lahir,
            alamat, no_telepon, foto_profile, created_at
     FROM siswa
     WHERE nis = ?`,
    [nis]
  );
  return rows;
}

async function updateFieldsByNis(nis, setClause, values) {
  // setClause: e.g. "jenis_kelamin = ?, alamat = ?"
  // values: [...fieldValues, nis]
  const [result] = await pool.query(
    `UPDATE siswa SET ${setClause} WHERE nis = ?`,
    values
  );
  return result;
}

async function findFotoByNis(nis) {
  const [rows] = await pool.query('SELECT foto_profile FROM siswa WHERE nis = ?', [nis]);
  return rows;
}

async function updateFotoByNis(nis, fotoPath) {
  const [result] = await pool.query(
    'UPDATE siswa SET foto_profile = ? WHERE nis = ?',
    [fotoPath, nis]
  );
  return result;
}

async function clearFotoByNis(nis) {
  const [result] = await pool.query(
    'UPDATE siswa SET foto_profile = NULL WHERE nis = ?',
    [nis]
  );
  return result;
}

async function findKelasByNis(nis) {
  const [rows] = await pool.query('SELECT kelas FROM siswa WHERE nis = ?', [nis]);
  return rows;
}

async function updateKelasByNis(nis, kelas) {
  const [result] = await pool.query('UPDATE siswa SET kelas = ? WHERE nis = ?', [kelas, nis]);
  return result;
}

async function findIdAndKelasByNis(nis) {
  const [rows] = await pool.query('SELECT id, kelas, nama FROM siswa WHERE nis = ?', [nis]);
  return rows;
}

async function findNisById(id) {
  const [rows] = await pool.query('SELECT nis FROM siswa WHERE id = ?', [id]);
  return rows;
}

async function findIdOnlyByNis(nis) {
  const [rows] = await pool.query('SELECT id FROM siswa WHERE nis = ?', [nis]);
  return rows;
}


/** Pastikan kolom keamanan login ada (idempotent). */
async function ensureLoginSecurityColumns() {
  const alters = [
    "ADD COLUMN failed_login_attempts INT NOT NULL DEFAULT 0",
    "ADD COLUMN locked_until DATETIME NULL DEFAULT NULL",
  ];
  for (const clause of alters) {
    try {
      await pool.query(`ALTER TABLE siswa ${clause}`);
    } catch (err) {
      if (err.code !== 'ER_DUP_FIELDNAME') {
        console.error('❌ Error migrasi kolom keamanan login:', clause, err.message);
      }
    }
  }
}

/** Ambil data login security by NIS (tanpa cek password). */
async function findLoginSecurityByNis(nis) {
  const [rows] = await pool.query(
    `SELECT id, nis, nama, kelas, foto_profile, password,
            COALESCE(failed_login_attempts, 0) AS failed_login_attempts,
            locked_until
     FROM siswa WHERE nis = ?`,
    [nis]
  );
  return rows;
}

async function incrementFailedLogin(nis) {
  await pool.query(
    'UPDATE siswa SET failed_login_attempts = COALESCE(failed_login_attempts, 0) + 1 WHERE nis = ?',
    [nis]
  );
  const [rows] = await pool.query(
    'SELECT COALESCE(failed_login_attempts, 0) AS failed_login_attempts FROM siswa WHERE nis = ?',
    [nis]
  );
  return rows[0]?.failed_login_attempts ?? 0;
}

async function lockAccount(nis, lockedUntil) {
  await pool.query(
    'UPDATE siswa SET locked_until = ?, failed_login_attempts = COALESCE(failed_login_attempts, 0) WHERE nis = ?',
    [lockedUntil, nis]
  );
}

async function resetLoginAttempts(nis) {
  await pool.query(
    'UPDATE siswa SET failed_login_attempts = 0, locked_until = NULL WHERE nis = ?',
    [nis]
  );
}


module.exports = {
  ensureLoginSecurityColumns,
  findLoginSecurityByNis,
  incrementFailedLogin,
  lockAccount,
  resetLoginAttempts,
  findIdByNis,
  findByNisAndPassword,
  insertSiswa,
  updateBasicByNis,
  listAllWithKelasAktif,
  findProfileByNis,
  updateFieldsByNis,
  findFotoByNis,
  updateFotoByNis,
  clearFotoByNis,
  findKelasByNis,
  updateKelasByNis,
  findIdAndKelasByNis,
  findNisById,
  findIdOnlyByNis,
};
