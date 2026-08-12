// routes/konselingRoutes.js
const express = require('express');
const { authenticate, requireRole, requireSelfOrStaff } = require('../middleware/auth');
const konselingController = require('../controllers/konselingController');
const konselingService = require('../services/konselingService');

const router = express.Router();

// Migrasi kolom tabel konseling saat modul dimuat
konselingService.initMigrations();

// Path spesifik dulu (sebelum /konseling/:nis atau /:id)
router.get('/konseling-all', authenticate, requireRole('kepsek', 'admin'), konselingController.listAll);
router.get('/konseling-bk', authenticate, requireRole('guru', 'admin'), konselingController.listByGuru);
router.get('/konseling/detail/:id', authenticate, requireRole('siswa', 'guru', 'kepsek', 'admin'), konselingController.getDetail);
router.post('/konseling/walkin', authenticate, requireRole('guru', 'admin'), konselingController.walkin);
router.post('/konseling/lanjutan', authenticate, requireRole('guru', 'admin'), konselingController.createLanjutan);
router.put('/konseling/:id/konfirmasi', authenticate, requireRole('guru', 'admin'), konselingController.konfirmasi);
router.put('/konseling/:id/status', authenticate, requireRole('guru', 'admin'), konselingController.updateStatus);
router.put('/konseling/:id/laporan', authenticate, requireRole('guru', 'admin'), konselingController.simpanLaporan);
router.put('/konseling/:id/batal-siswa', authenticate, requireRole('siswa'), konselingController.batalkanOlehSiswa);
router.delete('/konseling/:id', authenticate, requireRole('siswa', 'guru', 'admin'), konselingController.batalkan);
router.get('/konseling/:nis', authenticate, requireSelfOrStaff('nis'), konselingController.listByNis);
router.post('/konseling', authenticate, requireRole('siswa'), konselingController.create);

module.exports = router;
