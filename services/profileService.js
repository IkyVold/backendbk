// services/profileService.js
// Logika bisnis profil siswa (get, update data, upload/hapus foto).
const fs = require('fs');
const path = require('path');
const HttpError = require('../utils/HttpError');
const { VALID_KELAS_LIST } = require('./siswaService');
const siswaModel = require('../models/siswaModel');

const UPLOADS_DIR = path.join(__dirname, '..', 'uploads');

function resolveUploadFilePath(fotoProfileUrl) {
  // foto_profile disimpan sebagai "/uploads/siswa/xxx.jpg"
  if (!fotoProfileUrl || !fotoProfileUrl.startsWith('/uploads/')) return null;
  return path.join(UPLOADS_DIR, fotoProfileUrl.replace('/uploads/', ''));
}

function unlinkQuiet(filePath) {
  if (!filePath) return;
  fs.unlink(filePath, () => {});
}

/** Ambil profil lengkap siswa by NIS. */
async function getProfile(nis) {
  const rows = await siswaModel.findProfileByNis(nis);

  if (rows.length === 0) {
    throw new HttpError(404, 'Siswa tidak ditemukan');
  }

  return rows[0];
}

/**
 * Update field profil yang dikirim.
 * Field opsional: jenis_kelamin, tanggal_lahir, alamat, no_telepon, kelas.
 */
async function updateProfile(nis, body) {
  const { jenis_kelamin, tanggal_lahir, alamat, no_telepon, kelas } = body;

  const updates = [];
  const values = [];

  if (jenis_kelamin !== undefined) {
    updates.push('jenis_kelamin = ?');
    values.push(jenis_kelamin);
  }
  if (tanggal_lahir !== undefined) {
    updates.push('tanggal_lahir = ?');
    values.push(tanggal_lahir);
  }
  if (alamat !== undefined) {
    updates.push('alamat = ?');
    values.push(alamat);
  }
  if (no_telepon !== undefined) {
    updates.push('no_telepon = ?');
    values.push(no_telepon);
  }
  if (kelas !== undefined) {
    if (!VALID_KELAS_LIST.includes(kelas)) {
      throw new HttpError(400, 'Kelas tidak valid');
    }
    updates.push('kelas = ?');
    values.push(kelas);
  }

  if (updates.length === 0) {
    throw new HttpError(400, 'Tidak ada data yang diupdate');
  }

  values.push(nis);

  const result = await siswaModel.updateFieldsByNis(nis, updates.join(', '), values);

  if (result.affectedRows === 0) {
    throw new HttpError(404, 'Siswa tidak ditemukan');
  }

  return { message: 'Profile berhasil diupdate' };
}

/**
 * Simpan foto profil baru (file sudah di-upload multer ke disk).
 * @param {string} nis
 * @param {{ filename: string, path: string }} file — objek req.file dari multer
 */
async function updateFoto(nis, file) {
  if (!file) {
    throw new HttpError(400, 'File foto wajib diunggah');
  }

  const existingRows = await siswaModel.findFotoByNis(nis);

  if (existingRows.length === 0) {
    // Hapus file yang terlanjur ke-upload supaya tidak jadi sampah
    unlinkQuiet(file.path);
    throw new HttpError(404, 'Siswa tidak ditemukan');
  }

  const fotoPath = `/uploads/siswa/${file.filename}`;
  await siswaModel.updateFotoByNis(nis, fotoPath);

  // Hapus file foto lama
  const oldFoto = existingRows[0].foto_profile;
  unlinkQuiet(resolveUploadFilePath(oldFoto));

  return {
    message: 'Foto profile berhasil diupdate',
    foto_profile: fotoPath,
  };
}

/** Hapus foto profil (kembali ke avatar inisial default). */
async function deleteFoto(nis) {
  const existingRows = await siswaModel.findFotoByNis(nis);

  if (existingRows.length === 0) {
    throw new HttpError(404, 'Siswa tidak ditemukan');
  }

  await siswaModel.clearFotoByNis(nis);

  unlinkQuiet(resolveUploadFilePath(existingRows[0].foto_profile));

  return { message: 'Foto profile berhasil dihapus' };
}

module.exports = {
  getProfile,
  updateProfile,
  updateFoto,
  deleteFoto,
};
