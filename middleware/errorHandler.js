// middleware/errorHandler.js
const HttpError = require('../utils/HttpError');

// Bungkus route async supaya error di dalamnya otomatis lempar ke error handler,
// tanpa perlu try/catch berulang di tiap controller.
function asyncHandler(fn) {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

// Middleware terakhir di rantai Express: semua error (HttpError maupun error
// tak terduga) berakhir di sini dan diformat jadi respons JSON yang konsisten.
function errorHandler(err, req, res, next) { // eslint-disable-line no-unused-vars
  if (err instanceof HttpError) {
    return res.status(err.statusCode).json({ error: err.message });
  }

  console.error('Unhandled error:', err);
  return res.status(500).json({ error: 'Terjadi kesalahan server' });
}

module.exports = { asyncHandler, errorHandler };
