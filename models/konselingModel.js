// models/konselingModel.js
// Akses data tabel `konseling` — pure query.
const pool = require('../database');

const SELECT_KONSELING_FULL = `
  k.id,
  k.guru_id,
  COALESCE(g.nama, k.guru_bk) AS guru,
  k.guru_bk AS guru_bk_snapshot,
  DATE_FORMAT(k.tanggal, '%Y-%m-%d') AS tanggal,
  TIME_FORMAT(k.jam, '%H:%i') AS jam,
  k.jenis,
  k.kategori,
  k.deskripsi,
  k.kelas_siswa,
  k.status,
  k.status_konfirmasi,
  DATE_FORMAT(k.tanggal_konfirmasi, '%Y-%m-%d') AS tanggal_konfirmasi,
  TIME_FORMAT(k.jam_konfirmasi, '%H:%i') AS jam_konfirmasi,
  k.laporan,
  k.laporan_kesimpulan,
  k.laporan_rekomendasi,
  k.laporan_status_penanganan,
  k.laporan_catatan_tambahan,
  k.laporan_dibuat_oleh,
  DATE_FORMAT(k.laporan_tanggal, '%Y-%m-%d') AS laporan_tanggal,
  TIME_FORMAT(k.laporan_waktu, '%H:%i') AS laporan_waktu,
  k.laporan_created_at,
  k.alasan_batal,
  k.pengajuan_sebelumnya_id,
  k.input_manual,
  k.catatan_walkin,
  k.created_at
`;

async function runAlter(sql) {
  await pool.query(sql);
}

async function insertPengajuan({
  siswaId, guru_id, guru_bk, tanggal, jam, jenis, kategori, deskripsi, kelasSnapshot,
  pengajuan_sebelumnya_id = null,
}) {
  const [result] = await pool.query(
    `INSERT INTO konseling (siswa_id, guru_id, guru_bk, tanggal, jam, jenis, kategori, deskripsi, kelas_siswa, status, pengajuan_sebelumnya_id)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Proses', ?)`,
    [siswaId, guru_id || null, guru_bk, tanggal, jam, jenis, kategori, deskripsi, kelasSnapshot, pengajuan_sebelumnya_id]
  );
  return result;
}

async function listAll() {
  const [rows] = await pool.query(
    `SELECT
      ${SELECT_KONSELING_FULL},
      s.nis,
      s.nama AS nama_siswa,
      s.jenis_kelamin,
      DATE_FORMAT(s.tanggal_lahir, '%Y-%m-%d') AS tanggal_lahir,
      s.alamat
     FROM konseling k
     JOIN siswa s ON s.id = k.siswa_id
     LEFT JOIN guru_bk g ON g.id = k.guru_id
     ORDER BY k.tanggal DESC, k.jam DESC, k.id DESC`
  );
  return rows;
}

/** List by guru_id (preferred) with fallback nama untuk data lama. */
async function listByGuru({ guruId = null, guruNama = null } = {}) {
  const params = [];
  let where;
  if (guruId) {
    where = '(k.guru_id = ? OR (k.guru_id IS NULL AND k.guru_bk = ?))';
    params.push(guruId, guruNama || '');
  } else if (guruNama) {
    where = '(k.guru_bk = ? OR g.nama = ?)';
    params.push(guruNama, guruNama);
  } else {
    throw new Error('guruId atau guruNama wajib');
  }
  const [rows] = await pool.query(
    `SELECT
      ${SELECT_KONSELING_FULL},
      s.nis,
      s.nama AS nama_siswa,
      s.foto_profile AS foto_siswa
     FROM konseling k
     JOIN siswa s ON s.id = k.siswa_id
     LEFT JOIN guru_bk g ON g.id = k.guru_id
     WHERE ${where}
     ORDER BY k.tanggal DESC, k.jam DESC, k.id DESC`,
    params
  );
  return rows;
}

async function findForKonfirmasi(id) {
  const [rows] = await pool.query(
    `SELECT k.id, k.siswa_id, k.guru_id, k.guru_bk, k.status, k.status_konfirmasi,
            DATE_FORMAT(k.tanggal, '%Y-%m-%d') AS tanggalLama,
            TIME_FORMAT(k.jam, '%H:%i') AS jamLama,
            s.nis
     FROM konseling k
     JOIN siswa s ON s.id = k.siswa_id
     WHERE k.id = ?`,
    [id]
  );
  return rows;
}

async function updateKonfirmasi(id, { tanggal, jam }) {
  const [result] = await pool.query(
    `UPDATE konseling
     SET tanggal = ?, jam = ?, tanggal_konfirmasi = ?, jam_konfirmasi = ?, status_konfirmasi = 'Terkonfirmasi'
     WHERE id = ? AND status = 'Proses'`,
    [tanggal, jam, tanggal, jam, id]
  );
  return result;
}

async function findForStatus(id) {
  const [rows] = await pool.query(
    `SELECT k.id, k.siswa_id, k.guru_id, k.guru_bk, k.status, k.status_konfirmasi, k.jenis,
            DATE_FORMAT(k.tanggal, '%Y-%m-%d') AS tanggal,
            TIME_FORMAT(k.jam, '%H:%i') AS jam,
            s.nis
     FROM konseling k
     JOIN siswa s ON s.id = k.siswa_id
     WHERE k.id = ?`,
    [id]
  );
  return rows;
}

async function updateStatus(id, status) {
  // Hanya boleh ubah jika status saat ini masih Proses (bukan final)
  const [result] = await pool.query(
    `UPDATE konseling SET status = ? WHERE id = ? AND status = 'Proses'`,
    [status, id]
  );
  return result;
}

async function findLaporanCreatedAt(id) {
  const [rows] = await pool.query(
    'SELECT laporan_created_at FROM konseling WHERE id = ?',
    [id]
  );
  return rows;
}

async function updateLaporanEdit(id, {
  kesimpulan, rekomendasi, statusPenanganan, catatanTambahan,
}) {
  await pool.query(
    `UPDATE konseling
     SET laporan_kesimpulan = ?,
         laporan_rekomendasi = ?,
         laporan_status_penanganan = ?,
         laporan_catatan_tambahan = ?
     WHERE id = ?`,
    [kesimpulan, rekomendasi, statusPenanganan, catatanTambahan, id]
  );
}

async function updateLaporanFirst(id, {
  kesimpulan, rekomendasi, statusPenanganan, catatanTambahan, dibuatOleh,
}) {
  const [result] = await pool.query(
    `UPDATE konseling
     SET laporan_kesimpulan = ?,
         laporan_rekomendasi = ?,
         laporan_status_penanganan = ?,
         laporan_catatan_tambahan = ?,
         laporan_dibuat_oleh = ?,
         laporan_tanggal = CURDATE(),
         laporan_waktu = CURTIME(),
         laporan_created_at = NOW(),
         status = 'Selesai'
     WHERE id = ? AND status = 'Proses' AND status_konfirmasi = 'Terkonfirmasi'`,
    [kesimpulan, rekomendasi, statusPenanganan, catatanTambahan, dibuatOleh, id]
  );
  return result;
}

async function insertWalkin({
  siswaId, guru_id, guru_bk, tanggal, jam, jenis, kategori, deskripsi, kelasSnapshot, catatanWalkin,
}) {
  const [result] = await pool.query(
    `INSERT INTO konseling
      (siswa_id, guru_id, guru_bk, tanggal, jam, jenis, kategori, deskripsi, kelas_siswa,
       status, status_konfirmasi, tanggal_konfirmasi, jam_konfirmasi,
       input_manual, catatan_walkin)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?,
             'Proses', 'Terkonfirmasi', ?, ?,
             1, ?)`,
    [
      siswaId, guru_id || null, guru_bk, tanggal, jam, jenis, kategori, deskripsi, kelasSnapshot,
      tanggal, jam,
      catatanWalkin || null,
    ]
  );
  return result;
}

async function findStatusById(id) {
  const [rows] = await pool.query('SELECT status FROM konseling WHERE id = ?', [id]);
  return rows;
}

/** Data untuk pembatalan oleh siswa: cek ownership + status. */
async function findForBatalkanSiswa(id) {
  const [rows] = await pool.query(
    `SELECT k.id, k.siswa_id, k.guru_id, k.status, k.guru_bk,
            DATE_FORMAT(k.tanggal, '%Y-%m-%d') AS tanggal,
            TIME_FORMAT(k.jam, '%H:%i') AS jam,
            s.nis, s.nama AS nama_siswa
     FROM konseling k
     JOIN siswa s ON s.id = k.siswa_id
     WHERE k.id = ?`,
    [id]
  );
  return rows;
}

async function updateBatalkanSiswa(id, alasan) {
  const [result] = await pool.query(
    `UPDATE konseling
     SET status = 'Dibatalkan', alasan_batal = ?
     WHERE id = ? AND status = 'Proses'`,
    [alasan, id]
  );
  return result;
}

async function deleteById(id) {
  await pool.query('DELETE FROM konseling WHERE id = ?', [id]);
}

async function listBySiswaId(siswaId) {
  const [rows] = await pool.query(
    `SELECT
      id,
      guru_bk AS guru,
      DATE_FORMAT(tanggal, '%Y-%m-%d') AS tanggal,
      TIME_FORMAT(jam, '%H:%i') AS jam,
      jenis,
      kategori,
      deskripsi,
      kelas_siswa,
      status,
      status_konfirmasi,
      DATE_FORMAT(tanggal_konfirmasi, '%Y-%m-%d') AS tanggal_konfirmasi,
      TIME_FORMAT(jam_konfirmasi, '%H:%i') AS jam_konfirmasi,
      laporan,
      DATE_FORMAT(laporan_tanggal, '%Y-%m-%d') AS laporan_tanggal,
      TIME_FORMAT(laporan_waktu, '%H:%i') AS laporan_waktu,
      laporan_dibuat_oleh,
      laporan_kesimpulan,
      laporan_rekomendasi,
      laporan_status_penanganan,
      laporan_catatan_tambahan,
      laporan_created_at,
      alasan_batal,
      pengajuan_sebelumnya_id,
      input_manual,
      catatan_walkin,
      created_at
     FROM konseling
     WHERE siswa_id = ?
     ORDER BY tanggal DESC, jam DESC, id DESC`,
    [siswaId]
  );
  return rows;
}

async function findDetailById(id) {
  const [rows] = await pool.query(
    `SELECT
      ${SELECT_KONSELING_FULL},
      s.nis,
      s.nama AS nama_siswa
     FROM konseling k
     JOIN siswa s ON s.id = k.siswa_id
     LEFT JOIN guru_bk g ON g.id = k.guru_id
     WHERE k.id = ?`,
    [id]
  );
  return rows;
}


/** Ambil data sesi untuk membuat lanjutan (ownership + status). */
async function findByIdForLanjutan(id) {
  const [rows] = await pool.query(
    `SELECT k.id, k.siswa_id, k.guru_id, k.guru_bk, k.jenis, k.kategori, k.deskripsi, k.kelas_siswa, k.status,
            k.pengajuan_sebelumnya_id,
            s.nis, s.nama AS nama_siswa
     FROM konseling k
     JOIN siswa s ON s.id = k.siswa_id
     WHERE k.id = ?`,
    [id]
  );
  return rows;
}

/** Anak langsung dari sebuah sesi (sesi lanjutan). */
async function findChildrenByParentId(parentId) {
  const [rows] = await pool.query(
    `SELECT id, status, status_konfirmasi,
            DATE_FORMAT(tanggal, '%Y-%m-%d') AS tanggal,
            TIME_FORMAT(jam, '%H:%i') AS jam,
            kategori, jenis
     FROM konseling
     WHERE pengajuan_sebelumnya_id = ?
     ORDER BY id ASC`,
    [parentId]
  );
  return rows;
}

/** Info ringkas parent untuk ditampilkan di detail. */
async function findParentBrief(parentId) {
  if (!parentId) return null;
  const [rows] = await pool.query(
    `SELECT id, status, status_konfirmasi,
            DATE_FORMAT(tanggal, '%Y-%m-%d') AS tanggal,
            TIME_FORMAT(jam, '%H:%i') AS jam,
            kategori, jenis,
            laporan_status_penanganan
     FROM konseling WHERE id = ?`,
    [parentId]
  );
  return rows[0] || null;
}


/** Cek bentrok jadwal guru (exclude id tertentu, exclude Dibatalkan). */
async function countJadwalBentrok({ guru_id = null, guru_bk = null, tanggal, jam, excludeId = null }) {
  let sql = `SELECT COUNT(*) AS cnt FROM konseling
    WHERE tanggal = ? AND jam = ?
      AND status <> 'Dibatalkan'`;
  const params = [tanggal, jam];
  if (guru_id) {
    sql += ' AND (guru_id = ? OR (guru_id IS NULL AND guru_bk = ?))';
    params.push(guru_id, guru_bk || '');
  } else {
    sql += ' AND guru_bk = ?';
    params.push(guru_bk);
  }
  if (excludeId) {
    sql += ' AND id <> ?';
    params.push(excludeId);
  }
  const [rows] = await pool.query(sql, params);
  return rows[0].cnt;
}

module.exports = {
  runAlter,
  insertPengajuan,
  listAll,
  listByGuru,
  findForKonfirmasi,
  updateKonfirmasi,
  findForStatus,
  updateStatus,
  findLaporanCreatedAt,
  updateLaporanEdit,
  updateLaporanFirst,
  insertWalkin,
  findStatusById,
  findForBatalkanSiswa,
  updateBatalkanSiswa,
  deleteById,
  listBySiswaId,
  findDetailById,
  countJadwalBentrok,
  findByIdForLanjutan,
  findChildrenByParentId,
  findParentBrief,
};
