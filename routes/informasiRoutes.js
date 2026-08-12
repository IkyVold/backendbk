// routes/informasiRoutes.js
const express = require('express');
const { authenticate, requireRole } = require('../middleware/auth');
const informasiController = require('../controllers/informasiController');
const informasiService = require('../services/informasiService');

const router = express.Router();

// Pastikan tabel ada saat modul dimuat
informasiService.initTable();

router.get('/informasi', authenticate, requireRole('siswa', 'guru', 'admin', 'kepsek'), informasiController.list);
router.post('/informasi', authenticate, requireRole('guru', 'admin'), informasiController.create);
router.put('/informasi/:id', authenticate, requireRole('guru', 'admin'), informasiController.update);
router.delete('/informasi/:id', authenticate, requireRole('guru', 'admin'), informasiController.remove);

module.exports = router;
