// controllers/authController.js
const authService = require('../services/authService');
const {
  signToken,
  setAuthCookie,
  setCsrfCookie,
  clearAuthCookie,
  clearCsrfCookie,
} = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');

const login = asyncHandler(async (req, res) => {
  const siswa = await authService.loginSiswa(req.body);
  const token = signToken({
    role: 'siswa',
    id: siswa.id,
    nis: siswa.nis,
    nama: siswa.nama,
  });
  setAuthCookie(res, token, 'siswa');
  setCsrfCookie(res);
  // Token tidak dikirim di body — disimpan HttpOnly cookie
  res.json({ success: true, token, siswa });
});

const logout = asyncHandler(async (req, res) => {
  const role = (req.body && req.body.role) || (req.user && req.user.role) || null;
  clearAuthCookie(res, role);
  if (!role) clearCsrfCookie(res);
  res.json({ success: true, message: 'Logout berhasil' });
});

module.exports = { login, logout };
