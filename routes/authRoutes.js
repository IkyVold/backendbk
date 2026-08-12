const express = require('express');
const authController = require('../controllers/authController');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.post('/login', authController.login);
router.post('/logout', authController.logout);
// logout tanpa wajib auth (cookie mungkin sudah expired)
router.post('/logout-public', authController.logout);

module.exports = router;
