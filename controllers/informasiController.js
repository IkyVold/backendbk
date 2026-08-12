// controllers/informasiController.js
const informasiService = require('../services/informasiService');
const { asyncHandler } = require('../middleware/errorHandler');

const list = asyncHandler(async (req, res) => {
  const rows = await informasiService.list(req.query.kategori);
  res.json(rows);
});

const create = asyncHandler(async (req, res) => {
  const result = await informasiService.create(req.body);
  res.json({ success: true, message: result.message, id: result.id });
});

const update = asyncHandler(async (req, res) => {
  const result = await informasiService.update(req.params.id, req.body);
  res.json({ success: true, message: result.message });
});

const remove = asyncHandler(async (req, res) => {
  const result = await informasiService.remove(req.params.id);
  res.json({ success: true, message: result.message });
});

module.exports = {
  list,
  create,
  update,
  remove,
};
