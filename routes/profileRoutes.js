// routes/profileRoutes.js
const express = require('express');
const path = require('path');
const fs = require('fs');
const profileController = require('../controllers/profileController');
const { authenticate, requireSelfOrStaff } = require('../middleware/auth');
const { handleSecureImageUpload } = require('../utils/imageUpload');

const router = express.Router();

const UPLOADS_DIR = path.join(__dirname, '..', 'uploads');
const FOTO_DIR = path.join(UPLOADS_DIR, 'siswa');
if (!fs.existsSync(FOTO_DIR)) {
  fs.mkdirSync(FOTO_DIR, { recursive: true });
}

const handleFotoUpload = handleSecureImageUpload('siswa');

// Nama handler harus sama dengan export di profileController: get, update, updateFoto, deleteFoto
router.get('/profile/:nis', authenticate, requireSelfOrStaff('nis'), profileController.get);
router.put('/profile/:nis', authenticate, requireSelfOrStaff('nis'), profileController.update);
router.put('/profile/:nis/foto', authenticate, requireSelfOrStaff('nis'), handleFotoUpload, profileController.updateFoto);
router.delete('/profile/:nis/foto', authenticate, requireSelfOrStaff('nis'), profileController.deleteFoto);

module.exports = router;
