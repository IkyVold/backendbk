// models/notifikasiModel.js
const pool = require('../database');

async function ensureNotifikasiTable() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS notifikasi (
      id INT AUTO_INCREMENT PRIMARY KEY,
      siswa_id INT NOT NULL,
      konseling_id INT NULL,
      tipe VARCHAR(30) NOT NULL DEFAULT 'jadwal',
      judul VARCHAR(150) NOT NULL,
      pesan TEXT NOT NULL,
      tanggal_lama DATE NULL,
      jam_lama TIME NULL,
      tanggal_baru DATE NULL,
      jam_baru TIME NULL,
      is_read TINYINT(1) NOT NULL DEFAULT 0,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_notifikasi_siswa (siswa_id, created_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  `);
}

async function ensurePushSubscriptionsTable() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS push_subscriptions (
      id INT AUTO_INCREMENT PRIMARY KEY,
      siswa_id INT NOT NULL,
      endpoint VARCHAR(500) NOT NULL,
      p256dh VARCHAR(255) NOT NULL,
      auth VARCHAR(255) NOT NULL,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      UNIQUE KEY uq_push_endpoint (endpoint(255)),
      INDEX idx_push_siswa (siswa_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  `);
}

async function upsertPushSubscription({ siswaId, endpoint, p256dh, auth }) {
  await pool.query(
    `INSERT INTO push_subscriptions (siswa_id, endpoint, p256dh, auth)
     VALUES (?, ?, ?, ?)
     ON DUPLICATE KEY UPDATE siswa_id = VALUES(siswa_id), p256dh = VALUES(p256dh), auth = VALUES(auth)`,
    [siswaId, endpoint, p256dh, auth]
  );
}

async function deletePushByEndpoint(endpoint) {
  await pool.query('DELETE FROM push_subscriptions WHERE endpoint = ?', [endpoint]);
}

async function deletePushById(id) {
  await pool.query('DELETE FROM push_subscriptions WHERE id = ?', [id]);
}

async function listPushBySiswaId(siswaId) {
  const [rows] = await pool.query(
    'SELECT id, endpoint, p256dh, auth FROM push_subscriptions WHERE siswa_id = ?',
    [siswaId]
  );
  return rows;
}

async function listBySiswaId(siswaId, limit) {
  const [rows] = await pool.query(
    `SELECT
      id, konseling_id AS konselingId, tipe, judul, pesan,
      DATE_FORMAT(tanggal_lama, '%Y-%m-%d') AS tanggalLama,
      TIME_FORMAT(jam_lama, '%H:%i') AS jamLama,
      DATE_FORMAT(tanggal_baru, '%Y-%m-%d') AS tanggalBaru,
      TIME_FORMAT(jam_baru, '%H:%i') AS jamBaru,
      is_read AS isRead,
      created_at AS createdAt
     FROM notifikasi
     WHERE siswa_id = ?
     ORDER BY created_at DESC
     LIMIT ?`,
    [siswaId, limit]
  );
  return rows;
}

async function countUnread(siswaId) {
  const [[{ unreadCount }]] = await pool.query(
    'SELECT COUNT(*) AS unreadCount FROM notifikasi WHERE siswa_id = ? AND is_read = 0',
    [siswaId]
  );
  return unreadCount;
}

async function markReadById(id) {
  const [result] = await pool.query('UPDATE notifikasi SET is_read = 1 WHERE id = ?', [id]);
  return result;
}

async function markAllReadBySiswaId(siswaId) {
  await pool.query(
    'UPDATE notifikasi SET is_read = 1 WHERE siswa_id = ? AND is_read = 0',
    [siswaId]
  );
}

async function insertJadwal({
  siswaId,
  konselingId,
  judul,
  pesan,
  tanggalLama,
  jamLama,
  tanggalBaru,
  jamBaru,
}) {
  const [result] = await pool.query(
    `INSERT INTO notifikasi
      (siswa_id, konseling_id, tipe, judul, pesan, tanggal_lama, jam_lama, tanggal_baru, jam_baru)
     VALUES (?, ?, 'jadwal', ?, ?, ?, ?, ?, ?)`,
    [
      siswaId,
      konselingId || null,
      judul,
      pesan,
      tanggalLama || null,
      jamLama || null,
      tanggalBaru || null,
      jamBaru || null,
    ]
  );
  return result;
}

/** Tabel notifikasi untuk Guru BK (terpisah dari notifikasi siswa). */
async function ensureNotifikasiGuruTable() {
  // Jika tabel lama ada tanpa kolom guru_username → drop & recreate (data notif guru belum kritis)
  try {
    const [cols] = await pool.query(
      `SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
       WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'notifikasi_guru'`
    );
    const names = cols.map((c) => c.COLUMN_NAME);
    if (names.length > 0 && !names.includes('guru_username')) {
      console.warn('⚠️  Tabel notifikasi_guru skema lama terdeteksi — di-recreate');
      await pool.query('DROP TABLE notifikasi_guru');
    }
  } catch (err) {
    console.warn('⚠️  Cek skema notifikasi_guru:', err.message);
  }

  await pool.query(`
    CREATE TABLE IF NOT EXISTS notifikasi_guru (
      id INT AUTO_INCREMENT PRIMARY KEY,
      guru_username VARCHAR(50) NOT NULL,
      konseling_id INT NULL,
      tipe VARCHAR(30) NOT NULL DEFAULT 'pengajuan',
      judul VARCHAR(150) NOT NULL,
      pesan TEXT NOT NULL,
      is_read TINYINT(1) NOT NULL DEFAULT 0,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_notif_guru_user (guru_username, created_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  `);
}

async function insertGuru({ guruUsername, konselingId, tipe, judul, pesan }) {
  await ensureNotifikasiGuruTable();
  const [result] = await pool.query(
    `INSERT INTO notifikasi_guru (guru_username, konseling_id, tipe, judul, pesan)
     VALUES (?, ?, ?, ?, ?)`,
    [guruUsername, konselingId || null, tipe || 'pengajuan', judul, pesan]
  );
  return result;
}

async function listByGuruUsername(username, limit) {
  // Pastikan tabel ada (idempotent) sebelum SELECT
  await ensureNotifikasiGuruTable();
  const safeLimit = Math.min(Math.max(parseInt(limit, 10) || 30, 1), 100);
  const [rows] = await pool.query(
    `SELECT
      id, konseling_id AS konselingId, tipe, judul, pesan,
      is_read AS isRead, created_at AS createdAt
     FROM notifikasi_guru
     WHERE guru_username = ?
     ORDER BY created_at DESC
     LIMIT ${safeLimit}`,
    [username]
  );
  return rows;
}

async function countUnreadGuru(username) {
  await ensureNotifikasiGuruTable();
  const [rows] = await pool.query(
    'SELECT COUNT(*) AS unreadCount FROM notifikasi_guru WHERE guru_username = ? AND is_read = 0',
    [username]
  );
  return rows[0]?.unreadCount ?? 0;
}

async function markReadGuruById(id) {
  const [result] = await pool.query(
    'UPDATE notifikasi_guru SET is_read = 1 WHERE id = ?',
    [id]
  );
  return result;
}

async function markAllReadByGuruUsername(username) {
  await pool.query(
    'UPDATE notifikasi_guru SET is_read = 1 WHERE guru_username = ? AND is_read = 0',
    [username]
  );
}

module.exports = {
  ensureNotifikasiTable,
  ensurePushSubscriptionsTable,
  upsertPushSubscription,
  deletePushByEndpoint,
  deletePushById,
  listPushBySiswaId,
  listBySiswaId,
  countUnread,
  markReadById,
  markAllReadBySiswaId,
  insertJadwal,
  ensureNotifikasiGuruTable,
  insertGuru,
  listByGuruUsername,
  countUnreadGuru,
  markReadGuruById,
  markAllReadByGuruUsername,
};
