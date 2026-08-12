// controllers/siswaController.js
const siswaService = require('../services/siswaService');
const { asyncHandler } = require('../middleware/errorHandler');
const HttpError = require('../utils/HttpError');

const create = asyncHandler(async (req, res) => {
  const result = await siswaService.createSiswa(req.body);
  res.json({ success: true, message: result.message });
});

const list = asyncHandler(async (req, res) => {
  const rows = await siswaService.listSiswa();
  res.json(rows);
});

const importExcel = asyncHandler(async (req, res) => {
  if (!req.file) {
    throw new HttpError(400, 'File Excel wajib diupload (field "file")');
  }
  const result = await siswaService.importFromExcel(req.file.buffer);
  res.json({ success: true, ...result });
});

const previewAbsen = asyncHandler(async (req, res) => {
  if (!req.file) {
    throw new HttpError(400, 'File Excel wajib diupload (field "file")');
  }
  const result = siswaService.previewAbsen(req.file.buffer);
  res.json({ success: true, ...result });
});

const importRows = asyncHandler(async (req, res) => {
  const result = await siswaService.importRows(req.body.rows);
  res.json({ success: true, ...result });
});

module.exports = {
  create,
  list,
  importExcel,
  previewAbsen,
  importRows,
};
