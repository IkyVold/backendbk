// routes/akunRoutes.js
const express = require('express');
const path = require('path');
const fs = require('fs');
const akunController = require('../controllers/akunController');
const akunService = require('../services/akunService');
const { authenticate, requireRole } = require('../middleware/auth');
const { handleSecureImageUpload } = require('../utils/imageUpload');

const router = express.Router();

// Init tabel + seed saat module di-load
akunService.initAkunTables();

const FOTO_GURU_DIR = path.join(__dirname, '..', 'uploads', 'guru');
if (!fs.existsSync(FOTO_GURU_DIR)) {
  fs.mkdirSync(FOTO_GURU_DIR, { recursive: true });
}

const handleFotoGuruUpload = handleSecureImageUpload('guru');

// Login
router.post('/login-guru', akunController.loginGuru);
router.post('/login-kepsek', akunController.loginKepsek);
router.post('/login-admin', akunController.loginAdmin);
router.post('/logout-role', akunController.logoutRole);

// Publik: daftar Guru BK aktif untuk siswa (Pilih Guru)
router.get('/guru-bk', authenticate, requireRole('siswa', 'guru', 'admin', 'kepsek'), akunController.listGuruPublic);

// Admin — kelola akun Guru BK
router.get('/admin/guru-bk', authenticate, requireRole('admin'), akunController.listGuruAdmin);
router.post('/admin/guru-bk', authenticate, requireRole('admin'), akunController.createGuru);
router.put('/admin/guru-bk/:id', authenticate, requireRole('admin'), akunController.updateGuru);
router.delete('/admin/guru-bk/:id', authenticate, requireRole('admin'), akunController.deleteGuru);

// Admin — kelola akun Kepala Sekolah
router.get('/admin/kepsek', authenticate, requireRole('admin'), akunController.listKepsekAdmin);
router.post('/admin/kepsek', authenticate, requireRole('admin'), akunController.createKepsek);
router.put('/admin/kepsek/:id', authenticate, requireRole('admin'), akunController.updateKepsek);
router.delete('/admin/kepsek/:id', authenticate, requireRole('admin'), akunController.deleteKepsek);

// Foto profil Guru BK (magic-bytes validated)
router.put('/guru-bk/:username/foto', authenticate, requireRole('guru'), handleFotoGuruUpload, akunController.updateFotoGuru);
router.delete('/guru-bk/:username/foto', authenticate, requireRole('guru'), akunController.deleteFotoGuru);

module.exports = router;
