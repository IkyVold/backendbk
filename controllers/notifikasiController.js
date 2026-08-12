// controllers/notifikasiController.js
const notifikasiService = require('../services/notifikasiService');
const { asyncHandler } = require('../middleware/errorHandler');
const HttpError = require('../utils/HttpError');

const getVapidPublicKey = asyncHandler(async (req, res) => {
  const result = notifikasiService.getVapidKey();
  res.json(result);
});

const subscribe = asyncHandler(async (req, res) => {
  // NIS selalu dari JWT — tidak boleh dari body client
  const body = { ...req.body, nis: req.user.nis };
  const result = await notifikasiService.subscribe(body);
  res.json({ success: true, message: result.message });
});

const unsubscribe = asyncHandler(async (req, res) => {
  const result = await notifikasiService.unsubscribe(req.body);
  res.json({ success: true, message: result.message });
});

const list = asyncHandler(async (req, res) => {
  if (req.user.role === 'siswa' && String(req.user.nis) !== String(req.params.nis)) {
    throw new HttpError(403, 'Anda hanya dapat mengakses notifikasi milik sendiri');
  }
  const data = await notifikasiService.listByNis(req.params.nis, req.query.limit);
  res.json(data);
});

const markRead = asyncHandler(async (req, res) => {
  await notifikasiService.markRead(req.params.id);
  res.json({ success: true });
});

const markAllRead = asyncHandler(async (req, res) => {
  if (req.user.role === 'siswa' && String(req.user.nis) !== String(req.params.nis)) {
    throw new HttpError(403, 'Anda hanya dapat mengakses notifikasi milik sendiri');
  }
  await notifikasiService.markAllRead(req.params.nis);
  res.json({ success: true });
});

const listGuru = asyncHandler(async (req, res) => {
  // Guru: selalu username dari JWT (abaikan param supaya tidak 403 karena beda casing/typo)
  let username = req.params.username;
  if (req.user.role === 'guru') {
    username = req.user.username;
  }
  const data = await notifikasiService.listByGuruUsername(username, req.query.limit);
  res.json(data);
});

const markReadGuru = asyncHandler(async (req, res) => {
  await notifikasiService.markReadGuru(req.params.id);
  res.json({ success: true });
});

const markAllReadGuru = asyncHandler(async (req, res) => {
  let username = req.params.username;
  if (req.user.role === 'guru') {
    username = req.user.username;
  }
  await notifikasiService.markAllReadGuru(username);
  res.json({ success: true });
});

module.exports = {
  getVapidPublicKey,
  subscribe,
  unsubscribe,
  list,
  markRead,
  markAllRead,
  listGuru,
  markReadGuru,
  markAllReadGuru,
};
