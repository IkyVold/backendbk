// utils/imageUpload.js
// Validasi gambar berdasarkan magic bytes (bukan MIME/client),
// simpan dengan nama UUID + ekstensi yang benar.
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const multer = require('multer');
const HttpError = require('./HttpError');

const MAX_BYTES = 2 * 1024 * 1024; // 2 MB

/**
 * Deteksi tipe gambar dari magic bytes.
 * @returns {{ mime: string, ext: string } | null}
 */
function detectImageType(buf) {
  if (!Buffer.isBuffer(buf) || buf.length < 12) return null;

  // JPEG: FF D8 FF
  if (buf[0] === 0xff && buf[1] === 0xd8 && buf[2] === 0xff) {
    return { mime: 'image/jpeg', ext: '.jpg' };
  }

  // PNG: 89 50 4E 47 0D 0A 1A 0A
  if (
    buf[0] === 0x89 &&
    buf[1] === 0x50 &&
    buf[2] === 0x4e &&
    buf[3] === 0x47 &&
    buf[4] === 0x0d &&
    buf[5] === 0x0a &&
    buf[6] === 0x1a &&
    buf[7] === 0x0a
  ) {
    return { mime: 'image/png', ext: '.png' };
  }

  // WebP: RIFF....WEBP
  if (
    buf[0] === 0x52 &&
    buf[1] === 0x49 &&
    buf[2] === 0x46 &&
    buf[3] === 0x46 &&
    buf[8] === 0x57 &&
    buf[9] === 0x45 &&
    buf[10] === 0x42 &&
    buf[11] === 0x50
  ) {
    return { mime: 'image/webp', ext: '.webp' };
  }

  return null;
}

/**
 * Multer memory storage — file di-buffer dulu, baru divalidasi & ditulis disk.
 */
function createMemoryUploader(fieldName = 'foto') {
  return multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: MAX_BYTES },
  }).single(fieldName);
}

/**
 * Middleware Express:
 * 1) Jalankan multer memory
 * 2) Cek magic bytes
 * 3) Tulis file ke disk dengan UUID + ekstensi hasil deteksi
 * 4) Isi req.file.filename / path seperti multer diskStorage
 *
 * @param {string} subDir  subfolder di uploads/ (mis. 'siswa' | 'guru')
 */
function handleSecureImageUpload(subDir) {
  const uploader = createMemoryUploader('foto');
  const targetDir = path.join(__dirname, '..', 'uploads', subDir);

  return (req, res, next) => {
    uploader(req, res, (err) => {
      if (err) {
        if (err instanceof multer.MulterError) {
          if (err.code === 'LIMIT_FILE_SIZE') {
            return next(new HttpError(400, 'Ukuran foto maksimal 2MB'));
          }
          return next(new HttpError(400, err.message || 'Gagal mengunggah foto'));
        }
        return next(new HttpError(400, err.message || 'Gagal mengunggah foto'));
      }

      if (!req.file || !req.file.buffer) {
        return next(new HttpError(400, 'File foto wajib diunggah'));
      }

      const detected = detectImageType(req.file.buffer);
      if (!detected) {
        return next(
          new HttpError(
            400,
            'File bukan gambar yang valid. Hanya JPEG, PNG, atau WebP yang diizinkan.'
          )
        );
      }

      try {
        fs.mkdirSync(targetDir, { recursive: true });
        const filename = `${crypto.randomUUID()}${detected.ext}`;
        const fullPath = path.join(targetDir, filename);
        fs.writeFileSync(fullPath, req.file.buffer);

        // Samakan bentuk req.file dengan multer diskStorage agar service lama tetap jalan
        req.file.filename = filename;
        req.file.path = fullPath;
        req.file.destination = targetDir;
        req.file.mimetype = detected.mime;
        // Hapus buffer dari memory reference (GC akan membersihkan)
        delete req.file.buffer;
        next();
      } catch (writeErr) {
        console.error('Gagal menulis file upload:', writeErr.message);
        return next(new HttpError(500, 'Gagal menyimpan file foto'));
      }
    });
  };
}

module.exports = {
  detectImageType,
  handleSecureImageUpload,
  MAX_BYTES,
};
