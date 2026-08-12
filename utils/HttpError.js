// utils/HttpError.js
// Error kustom yang membawa status HTTP, supaya controller cukup
// `throw new HttpError(400, 'pesan')` dan error handler yang urus responsnya.
class HttpError extends Error {
  constructor(statusCode, message) {
    super(message);
    this.name = 'HttpError';
    this.statusCode = statusCode;
  }
}

module.exports = HttpError;
