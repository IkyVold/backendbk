// routes/riwayatKelasRoutes.js
const express = require('express');
const riwayatKelasController = require('../controllers/riwayatKelasController');
const riwayatKelasService = require('../services/riwayatKelasService');
const { authenticate, requireRole, requireSelfOrStaff } = require('../middleware/auth');

const router = express.Router();

// Pastikan tabel ada saat modul dimuat (sama seperti init di server.js lama)
riwayatKelasService.initTable();

// Path lebih spesifik dulu
router.get('/riwayat-kelas/:nis/aktif', authenticate, requireSelfOrStaff('nis'), riwayatKelasController.getAktif);
router.get('/riwayat-kelas/:nis', authenticate, requireSelfOrStaff('nis'), riwayatKelasController.list);
router.post('/riwayat-kelas', authenticate, requireRole('guru', 'admin'), riwayatKelasController.create);
router.delete('/riwayat-kelas/:id', authenticate, requireRole('guru', 'admin'), riwayatKelasController.remove);

module.exports = router;
