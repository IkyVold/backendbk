// routes/chatRoutes.js
const express = require('express');
const { authenticate, requireRole } = require('../middleware/auth');
const chatController = require('../controllers/chatController');

const router = express.Router();

router.post('/chat', authenticate, requireRole('siswa', 'guru', 'admin'), chatController.chat);

module.exports = router;
