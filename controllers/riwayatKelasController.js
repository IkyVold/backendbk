// controllers/riwayatKelasController.js
const riwayatKelasService = require('../services/riwayatKelasService');
const { asyncHandler } = require('../middleware/errorHandler');

const list = asyncHandler(async (req, res) => {
  const rows = await riwayatKelasService.listByNis(req.params.nis);
  res.json(rows);
});

const getAktif = asyncHandler(async (req, res) => {
  const data = await riwayatKelasService.getAktif(req.params.nis);
  res.json(data);
});

const create = asyncHandler(async (req, res) => {
  const result = await riwayatKelasService.upsert(req.body);
  res.json({ success: true, message: result.message });
});

const remove = asyncHandler(async (req, res) => {
  const result = await riwayatKelasService.remove(req.params.id);
  res.json({ success: true, message: result.message });
});

module.exports = {
  list,
  getAktif,
  create,
  remove,
};
