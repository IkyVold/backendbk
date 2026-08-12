// routes/siswaRoutes.js
const express = require('express');
const multer = require('multer');
const siswaController = require('../controllers/siswaController');
const { authenticate, requireRole } = require('../middleware/auth');

const router = express.Router();

// Upload Excel ke memory (sama seperti di server.js lama)
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 },
});

// Urutan route penting: path spesifik (/import, /import-absen/...) sebelum /:param jika ada
router.get('/siswa', authenticate, requireRole('guru', 'admin'), siswaController.list);
router.post('/siswa', authenticate, requireRole('guru', 'admin'), siswaController.create);
router.post('/siswa/import', authenticate, requireRole('guru', 'admin'), upload.single('file'), siswaController.importExcel);
router.post('/siswa/import-absen/preview', authenticate, requireRole('guru', 'admin'), upload.single('file'), siswaController.previewAbsen);
router.post('/siswa/import-rows', authenticate, requireRole('guru', 'admin'), siswaController.importRows);

module.exports = router;
