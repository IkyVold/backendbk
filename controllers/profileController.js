// controllers/profileController.js
const profileService = require('../services/profileService');
const { asyncHandler } = require('../middleware/errorHandler');

const get = asyncHandler(async (req, res) => {
  const profile = await profileService.getProfile(req.params.nis);
  res.json(profile);
});

const update = asyncHandler(async (req, res) => {
  const result = await profileService.updateProfile(req.params.nis, req.body);
  res.json({ success: true, message: result.message });
});

const updateFoto = asyncHandler(async (req, res) => {
  const result = await profileService.updateFoto(req.params.nis, req.file);
  res.json({
    success: true,
    message: result.message,
    foto_profile: result.foto_profile,
  });
});

const deleteFoto = asyncHandler(async (req, res) => {
  const result = await profileService.deleteFoto(req.params.nis);
  res.json({ success: true, message: result.message });
});

module.exports = {
  get,
  update,
  updateFoto,
  deleteFoto,
};
