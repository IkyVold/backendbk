// services/authService.js
// Verifikasi & orkestrasi registrasi/login siswa + proteksi brute-force.
const HttpError = require('../utils/HttpError');
const siswaModel = require('../models/siswaModel');

const MAX_FAILED_ATTEMPTS = 5;
const LOCK_DURATION_MS = 24 * 60 * 60 * 1000; // 1 hari

let securityColumnsReady = false;

async function ensureSecurityReady() {
  if (securityColumnsReady) return;
  await siswaModel.ensureLoginSecurityColumns();
  securityColumnsReady = true;
}

async function registerSiswa({ nis, nama, kelas, jenis_kelamin, password }) {
  // Self-registration publik dinonaktifkan — akun siswa dibuat oleh Guru BK.
  throw new HttpError(403, 'Registrasi mandiri tidak tersedia. Hubungi Guru BK untuk pembuatan akun.');
}

/**
 * Login siswa.
 * Setelah 5x gagal, akun dikunci selama 1 hari (locked_until).
 */
async function loginSiswa({ nis, password }) {
  if (!nis || !password) {
    throw new HttpError(400, 'NIS dan password harus diisi');
  }

  await ensureSecurityReady();

  const rows = await siswaModel.findLoginSecurityByNis(nis);
  if (rows.length === 0) {
    // Jangan bocorkan apakah NIS ada atau tidak — pesan generik
    throw new HttpError(401, 'NIS atau password salah');
  }

  const siswa = rows[0];
  const now = new Date();

  // Cek apakah akun masih terkunci
  if (siswa.locked_until) {
    const lockedUntil = new Date(siswa.locked_until);
    if (lockedUntil > now) {
      const jam = lockedUntil.toLocaleString('id-ID', {
        timeZone: 'Asia/Jakarta',
        dateStyle: 'medium',
        timeStyle: 'short',
      });
      throw new HttpError(
        423,
        `Akun terkunci karena terlalu banyak percobaan login gagal. Coba lagi setelah ${jam} WIB.`
      );
    }
    // Masa kunci sudah lewat — reset counter
    await siswaModel.resetLoginAttempts(nis);
  }

  // Verifikasi password (MD5, sama seperti sebelumnya)
  const matchRows = await siswaModel.findByNisAndPassword(nis, password);
  if (matchRows.length === 0) {
    const attempts = await siswaModel.incrementFailedLogin(nis);

    if (attempts >= MAX_FAILED_ATTEMPTS) {
      const lockedUntil = new Date(Date.now() + LOCK_DURATION_MS);
      await siswaModel.lockAccount(nis, lockedUntil);
      throw new HttpError(
        423,
        'Akun dikunci selama 1 hari karena 5 kali login gagal. Hubungi Guru BK jika ini bukan Anda.'
      );
    }

    // Pesan generik sama seperti NIS tidak ditemukan — cegah user enumeration
    throw new HttpError(401, 'NIS atau password salah');
  }

  // Login sukses — reset counter & kunci
  await siswaModel.resetLoginAttempts(nis);

  // Kembalikan field yang sama seperti sebelumnya (tanpa password / internal fields)
  return {
    id: matchRows[0].id,
    nis: matchRows[0].nis,
    nama: matchRows[0].nama,
    kelas: matchRows[0].kelas,
    foto_profile: matchRows[0].foto_profile,
  };
}

module.exports = { registerSiswa, loginSiswa };
