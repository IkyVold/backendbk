// routes/notifikasiRoutes.js
const express = require('express');
const { authenticate, requireRole, requireSelfOrStaff } = require('../middleware/auth');
const notifikasiController = require('../controllers/notifikasiController');
const notifikasiService = require('../services/notifikasiService');

const router = express.Router();

// Pastikan tabel notifikasi & push_subscriptions ada saat modul dimuat
notifikasiService.initTables();

// Web Push
router.get('/push/vapid-public-key', authenticate, notifikasiController.getVapidPublicKey);
router.post('/push/subscribe', authenticate, requireRole('siswa'), notifikasiController.subscribe);
router.post('/push/unsubscribe', authenticate, requireRole('siswa'), notifikasiController.unsubscribe);

// Riwayat notifikasi Guru BK (path spesifik dulu)
router.get('/notifikasi-guru/:username', authenticate, requireRole('guru', 'admin'), notifikasiController.listGuru);
router.put('/notifikasi-guru/:id/read', authenticate, requireRole('guru', 'admin'), notifikasiController.markReadGuru);
router.put('/notifikasi-guru/:username/read-all', authenticate, requireRole('guru', 'admin'), notifikasiController.markAllReadGuru);

// Riwayat notifikasi siswa (path spesifik dulu)
router.put('/notifikasi/:id/read', authenticate, requireRole('siswa', 'guru', 'admin'), notifikasiController.markRead);
router.put('/notifikasi/:nis/read-all', authenticate, requireSelfOrStaff('nis'), notifikasiController.markAllRead);
router.get('/notifikasi/:nis', authenticate, requireSelfOrStaff('nis'), notifikasiController.list);

module.exports = router;
