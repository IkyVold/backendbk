// controllers/akunController.js
const akunService = require('../services/akunService');
const { signToken } = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');

const loginGuru = asyncHandler(async (req, res) => {
  const guru = await akunService.loginGuru(req.body);
  const token = signToken({
    role: 'guru',
    id: guru.id,
    username: guru.username,
    nama: guru.nama,
  });
  const { setAuthCookie, setCsrfCookie } = require('../middleware/auth');
  setAuthCookie(res, token, 'guru');
  setCsrfCookie(res);
  res.json({ success: true, token, guru });
});

const loginKepsek = asyncHandler(async (req, res) => {
  const kepsek = await akunService.loginKepsek(req.body);
  const token = signToken({
    role: 'kepsek',
    id: kepsek.id,
    username: kepsek.username,
    nama: kepsek.nama,
  });
  const { setAuthCookie, setCsrfCookie } = require('../middleware/auth');
  setAuthCookie(res, token, 'kepsek');
  setCsrfCookie(res);
  res.json({ success: true, token, kepsek });
});

const loginAdmin = asyncHandler(async (req, res) => {
  const admin = await akunService.loginAdmin(req.body);
  const token = signToken({
    role: 'admin',
    id: admin.id,
    username: admin.username,
    nama: admin.nama,
  });
  const { setAuthCookie, setCsrfCookie } = require('../middleware/auth');
  setAuthCookie(res, token, 'admin');
  setCsrfCookie(res);
  res.json({ success: true, token, admin });
});

const listGuruPublic = asyncHandler(async (req, res) => {
  const list = await akunService.listGuruPublic();
  res.json({ success: true, data: list });
});

const listGuruAdmin = asyncHandler(async (req, res) => {
  const list = await akunService.listGuruAdmin();
  res.json({ success: true, data: list });
});

const createGuru = asyncHandler(async (req, res) => {
  const result = await akunService.createGuru(req.body);
  res.status(201).json({ success: true, ...result });
});

const updateGuru = asyncHandler(async (req, res) => {
  const result = await akunService.updateGuru(req.params.id, req.body);
  res.json({ success: true, ...result });
});

const deleteGuru = asyncHandler(async (req, res) => {
  const result = await akunService.deleteGuru(req.params.id);
  res.json({ success: true, ...result });
});

const listKepsekAdmin = asyncHandler(async (req, res) => {
  const list = await akunService.listKepsekAdmin();
  res.json({ success: true, data: list });
});

const createKepsek = asyncHandler(async (req, res) => {
  const result = await akunService.createKepsek(req.body);
  res.status(201).json({ success: true, ...result });
});

const updateKepsek = asyncHandler(async (req, res) => {
  const result = await akunService.updateKepsek(req.params.id, req.body);
  res.json({ success: true, ...result });
});

const deleteKepsek = asyncHandler(async (req, res) => {
  const result = await akunService.deleteKepsek(req.params.id);
  res.json({ success: true, ...result });
});

const updateFotoGuru = asyncHandler(async (req, res) => {
  const HttpError = require('../utils/HttpError');
  if (req.user.role === 'guru' && String(req.user.username) !== String(req.params.username)) {
    throw new HttpError(403, 'Anda hanya dapat mengubah foto profil sendiri');
  }
  const result = await akunService.updateFotoGuru(req.params.username, req.file);
  res.json({ success: true, ...result });
});

const deleteFotoGuru = asyncHandler(async (req, res) => {
  const HttpError = require('../utils/HttpError');
  if (req.user.role === 'guru' && String(req.user.username) !== String(req.params.username)) {
    throw new HttpError(403, 'Anda hanya dapat mengubah foto profil sendiri');
  }
  const result = await akunService.deleteFotoGuru(req.params.username);
  res.json({ success: true, ...result });
});

const logoutRole = asyncHandler(async (req, res) => {
  const { clearAuthCookie } = require('../middleware/auth');
  const role = req.body?.role || req.user?.role;
  clearAuthCookie(res, role);
  res.json({ success: true, message: 'Logout berhasil' });
});

module.exports = {
  loginGuru,
  loginKepsek,
  loginAdmin,
  logoutRole,
  listGuruPublic,
  listGuruAdmin,
  createGuru,
  updateGuru,
  deleteGuru,
  listKepsekAdmin,
  createKepsek,
  updateKepsek,
  deleteKepsek,
  updateFotoGuru,
  deleteFotoGuru,
};
