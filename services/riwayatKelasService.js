// services/riwayatKelasService.js
// Logika bisnis riwayat kelas siswa.
const HttpError = require('../utils/HttpError');
const { VALID_KELAS_LIST } = require('./siswaService');
const riwayatKelasModel = require('../models/riwayatKelasModel');
const siswaModel = require('../models/siswaModel');

/** Pastikan tabel riwayat_kelas ada (idempotent). */
async function initTable() {
  try {
    await riwayatKelasModel.ensureTable();
    console.log('✅ Tabel riwayat_kelas siap');
  } catch (err) {
    console.error('❌ Error membuat tabel riwayat_kelas:', err.message);
  }
}

/** Semua riwayat kelas satu siswa, tahun terbaru dulu. */
async function listByNis(nis) {
  return riwayatKelasModel.listByNis(nis);
}

/**
 * Kelas aktif satu siswa.
 * Fallback ke kolom kelas di tabel siswa kalau belum ada riwayat aktif.
 */
async function getAktif(nis) {
  const rows = await riwayatKelasModel.findAktifByNis(nis);

  if (rows.length === 0) {
    const siswa = await siswaModel.findKelasByNis(nis);
    return {
      kelas: siswa[0]?.kelas || '-',
      tahun_ajaran: null,
      source: 'siswa',
    };
  }

  return { ...rows[0], source: 'riwayat' };
}

/**
 * Tambah/update riwayat (upsert by nis + tahun_ajaran).
 * Jika status aktif: arsipkan kelas aktif lain + sync kolom kelas di tabel siswa.
 */
async function upsert({ nis, tahun_ajaran, kelas, status }) {
  if (!nis || !tahun_ajaran || !kelas) {
    throw new HttpError(400, 'nis, tahun_ajaran, dan kelas wajib diisi');
  }

  if (!/^\d{4}\/\d{4}$/.test(tahun_ajaran)) {
    throw new HttpError(400, 'Format tahun ajaran harus: 2024/2025');
  }

  if (!VALID_KELAS_LIST.includes(kelas)) {
    throw new HttpError(400, 'Kelas tidak valid');
  }

  const statusVal = status === 'arsip' ? 'arsip' : 'aktif';

  if (statusVal === 'aktif') {
    await riwayatKelasModel.arsipkanAktifByNis(nis);
    await siswaModel.updateKelasByNis(nis, kelas);
  }

  await riwayatKelasModel.upsert({ nis, tahun_ajaran, kelas, status: statusVal });

  return { message: 'Riwayat kelas berhasil disimpan' };
}

/** Hapus satu entri by id. */
async function remove(id) {
  const result = await riwayatKelasModel.deleteById(id);
  if (result.affectedRows === 0) {
    throw new HttpError(404, 'Data tidak ditemukan');
  }
  return { message: 'Riwayat kelas berhasil dihapus' };
}

module.exports = {
  initTable,
  listByNis,
  getAktif,
  upsert,
  remove,
};
