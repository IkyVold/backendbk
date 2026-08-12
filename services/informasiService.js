// services/informasiService.js
// CRUD knowledge base FAQ (tabel informasi_bk) yang dikelola Guru BK.
const HttpError = require('../utils/HttpError');
const informasiModel = require('../models/informasiModel');

const KATEGORI_INFORMASI_LIST = [
  'Beasiswa',
  'Pendaftaran Perguruan Tinggi',
  'Bimbingan Karir',
  'Informasi Sekolah',
  'Informasi BK',
  'Umum',
];

/** Pastikan tabel informasi_bk ada (idempotent). */
async function initTable() {
  try {
    await informasiModel.ensureTable();
    console.log('✅ Tabel informasi_bk siap');
  } catch (err) {
    console.error('❌ Error membuat tabel informasi_bk:', err.message);
  }
}

/** List semua informasi, opsional filter by kategori. */
async function list(kategori) {
  return informasiModel.listAll(kategori);
}

/** Tambah informasi baru. */
async function create({ judul, kategori, isi, guru_bk }) {
  if (!judul || !kategori || !isi || !guru_bk) {
    throw new HttpError(400, 'Judul, kategori, isi, dan guru_bk wajib diisi');
  }
  if (!KATEGORI_INFORMASI_LIST.includes(kategori)) {
    throw new HttpError(400, 'Kategori tidak valid');
  }

  const result = await informasiModel.insert({
    judul: judul.trim(),
    kategori,
    isi: isi.trim(),
    guru_bk,
  });

  return {
    message: 'Informasi berhasil ditambahkan',
    id: result.insertId,
  };
}

/** Update informasi by id. */
async function update(id, { judul, kategori, isi }) {
  if (!judul || !kategori || !isi) {
    throw new HttpError(400, 'Judul, kategori, dan isi wajib diisi');
  }
  if (!KATEGORI_INFORMASI_LIST.includes(kategori)) {
    throw new HttpError(400, 'Kategori tidak valid');
  }

  const result = await informasiModel.updateById(id, {
    judul: judul.trim(),
    kategori,
    isi: isi.trim(),
  });

  if (result.affectedRows === 0) {
    throw new HttpError(404, 'Informasi tidak ditemukan');
  }

  return { message: 'Informasi berhasil diperbarui' };
}

/** Hapus informasi by id. */
async function remove(id) {
  const result = await informasiModel.deleteById(id);
  if (result.affectedRows === 0) {
    throw new HttpError(404, 'Informasi tidak ditemukan');
  }
  return { message: 'Informasi berhasil dihapus' };
}

module.exports = {
  KATEGORI_INFORMASI_LIST,
  initTable,
  list,
  create,
  update,
  remove,
};
