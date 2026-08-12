// models/riwayatKelasModel.js
const pool = require('../database');

async function ensureTable() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS riwayat_kelas (
      id INT AUTO_INCREMENT PRIMARY KEY,
      nis VARCHAR(20) NOT NULL,
      tahun_ajaran VARCHAR(9) NOT NULL COMMENT 'Format: 2024/2025',
      kelas VARCHAR(20) NOT NULL,
      status ENUM('aktif','arsip') DEFAULT 'aktif',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      UNIQUE KEY unique_nis_tahun (nis, tahun_ajaran)
    )
  `);
}

async function listByNis(nis) {
  const [rows] = await pool.query(
    'SELECT * FROM riwayat_kelas WHERE nis = ? ORDER BY tahun_ajaran DESC',
    [nis]
  );
  return rows;
}

async function findAktifByNis(nis) {
  const [rows] = await pool.query(
    'SELECT kelas, tahun_ajaran FROM riwayat_kelas WHERE nis = ? AND status = "aktif" LIMIT 1',
    [nis]
  );
  return rows;
}

async function arsipkanAktifByNis(nis) {
  await pool.query(
    'UPDATE riwayat_kelas SET status = "arsip" WHERE nis = ? AND status = "aktif"',
    [nis]
  );
}

async function upsert({ nis, tahun_ajaran, kelas, status }) {
  await pool.query(
    `INSERT INTO riwayat_kelas (nis, tahun_ajaran, kelas, status)
     VALUES (?, ?, ?, ?)
     ON DUPLICATE KEY UPDATE kelas = VALUES(kelas), status = VALUES(status)`,
    [nis, tahun_ajaran, kelas, status]
  );
}

async function deleteById(id) {
  const [result] = await pool.query('DELETE FROM riwayat_kelas WHERE id = ?', [id]);
  return result;
}

module.exports = {
  ensureTable,
  listByNis,
  findAktifByNis,
  arsipkanAktifByNis,
  upsert,
  deleteById,
};
