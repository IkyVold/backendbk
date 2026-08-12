// services/akunService.js
// Seed + login Guru BK / Kepsek / Admin + CRUD oleh admin.
const fs = require('fs');
const path = require('path');
const HttpError = require('../utils/HttpError');
const guruBkModel = require('../models/guruBkModel');
const kepsekModel = require('../models/kepsekModel');
const adminModel = require('../models/adminModel');

function initials(nama) {
  if (!nama) return 'G';
  return nama
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((w) => w[0].toUpperCase())
    .join('');
}

/** Buat tabel + seed akun default (hanya jika tabel masih kosong). */
async function initAkunTables() {
  try {
    await guruBkModel.ensureTable();
    await guruBkModel.ensureFotoColumn();
    await kepsekModel.ensureTable();
    await adminModel.ensureTable();

    if ((await adminModel.countAll()) === 0) {
      await adminModel.insert({
        username: 'admin',
        password: 'admin123',
        nama: 'Admin',
      });
      console.log('✅ Seed admin_master: username=admin password=admin123');
    }

    // Seed guru BK demo agar data konseling lama (berdasarkan nama) tetap cocok
    if ((await guruBkModel.countAll()) === 0) {
      const seeds = [
        { username: 'joko_bk', password: 'guru123', nama: 'Joko Ardianto S.Pd', npsn: '023497329432', alamat: 'Blitar' },
        { username: 'wiwiek_bk', password: 'guru123', nama: 'wiwiek Hariati S.Pd', npsn: '023497329432', alamat: 'Blitar' },
        { username: 'dicky_bk', password: 'guru123', nama: 'Dicky Ardiansyah S.Pd', npsn: '023497329432', alamat: 'Blitar' },
      ];
      for (const s of seeds) {
        await guruBkModel.insert({
          ...s,
          spesialisasi: 'Guru BK',
          avatar: initials(s.nama),
        });
      }
      console.log('✅ Seed guru_bk default (3 akun)');
    }

    if ((await kepsekModel.countAll()) === 0) {
      const seeds = [
        {
          username: 'kepsek_sma', password: 'kepsek123',
          nama: 'Drs. H. Ahmad Fauzi, M.Pd', nip: '196805152005011001',
          sekolah: 'SMA Negeri 1 Blitar',
        },
        {
          username: 'kepsek_smk', password: 'kepsek123',
          nama: 'Dra. Siti Aminah, M.M', nip: '197203102006042002',
          sekolah: 'SMK Negeri 2 Blitar',
        },
      ];
      for (const s of seeds) {
        await kepsekModel.insert({
          ...s,
          jabatan: 'Kepala Sekolah',
          avatar: initials(s.nama),
        });
      }
      console.log('✅ Seed kepala_sekolah default (2 akun)');
    }

    console.log('✅ Tabel akun (admin/guru_bk/kepsek) siap');
  } catch (err) {
    console.error('❌ Error init akun tables:', err.message);
  }
}

// ---------- LOGIN ----------
async function loginGuru({ username, password }) {
  if (!username || !password) throw new HttpError(400, 'Username dan password harus diisi');
  const rows = await guruBkModel.findByUsernamePassword(username, password);
  if (rows.length === 0) throw new HttpError(401, 'Username atau password salah');
  return rows[0];
}

async function loginKepsek({ username, password }) {
  if (!username || !password) throw new HttpError(400, 'Username dan password harus diisi');
  const rows = await kepsekModel.findByUsernamePassword(username, password);
  if (rows.length === 0) throw new HttpError(401, 'Username atau password salah');
  return rows[0];
}

async function loginAdmin({ username, password }) {
  if (!username || !password) throw new HttpError(400, 'Username dan password harus diisi');
  const rows = await adminModel.findByUsernamePassword(username, password);
  if (rows.length === 0) throw new HttpError(401, 'Username atau password salah');
  return rows[0];
}

/** List Guru BK aktif untuk siswa (Pilih Guru). */
async function listGuruPublic() {
  return guruBkModel.listActivePublic();
}

// ---------- CRUD GURU BK (admin) ----------
async function listGuruAdmin() {
  return guruBkModel.listAll();
}

async function createGuru(body) {
  const { username, password, nama, spesialisasi, npsn, alamat } = body;
  if (!username || !password || !nama) {
    throw new HttpError(400, 'Username, password, dan nama wajib diisi');
  }
  if ((await guruBkModel.findByUsername(username)).length > 0) {
    throw new HttpError(400, 'Username sudah dipakai');
  }
  const result = await guruBkModel.insert({
    username: username.trim(),
    password,
    nama: nama.trim(),
    spesialisasi: (spesialisasi || 'Guru BK').trim(),
    npsn: npsn || null,
    alamat: alamat || null,
    avatar: initials(nama),
  });
  return { message: 'Akun Guru BK berhasil ditambahkan', id: result.insertId };
}

async function updateGuru(id, body) {
  const existing = await guruBkModel.findById(id);
  if (existing.length === 0) throw new HttpError(404, 'Akun Guru BK tidak ditemukan');

  if (body.username && body.username !== existing[0].username) {
    if ((await guruBkModel.findByUsername(body.username)).length > 0) {
      throw new HttpError(400, 'Username sudah dipakai');
    }
  }

  const payload = { ...body };
  if (payload.nama) payload.avatar = initials(payload.nama);
  const result = await guruBkModel.updateById(id, payload);
  if (result.affectedRows === 0) throw new HttpError(404, 'Akun Guru BK tidak ditemukan');
  return { message: 'Akun Guru BK berhasil diperbarui' };
}

/** Nonaktifkan akun — hilang dari Pilih Guru, riwayat konseling tetap. */
async function deleteGuru(id) {
  const result = await guruBkModel.softDelete(id);
  if (result.affectedRows === 0) throw new HttpError(404, 'Akun Guru BK tidak ditemukan');
  return { message: 'Akun Guru BK dinonaktifkan (tidak lagi muncul di Pilih Guru)' };
}

// ---------- CRUD KEPSEK (admin) ----------
async function listKepsekAdmin() {
  return kepsekModel.listAll();
}

async function createKepsek(body) {
  const { username, password, nama, nip, sekolah, jabatan } = body;
  if (!username || !password || !nama) {
    throw new HttpError(400, 'Username, password, dan nama wajib diisi');
  }
  if ((await kepsekModel.findByUsername(username)).length > 0) {
    throw new HttpError(400, 'Username sudah dipakai');
  }
  const result = await kepsekModel.insert({
    username: username.trim(),
    password,
    nama: nama.trim(),
    nip: nip || null,
    sekolah: sekolah || null,
    jabatan: jabatan || 'Kepala Sekolah',
    avatar: initials(nama),
  });
  return { message: 'Akun Kepala Sekolah berhasil ditambahkan', id: result.insertId };
}

async function updateKepsek(id, body) {
  if (body.username) {
    const rows = await kepsekModel.findByUsername(body.username);
    // allow same user; uniqueness checked simply
  }
  const payload = { ...body };
  if (payload.nama) payload.avatar = initials(payload.nama);
  const result = await kepsekModel.updateById(id, payload);
  if (result.affectedRows === 0) throw new HttpError(404, 'Akun Kepala Sekolah tidak ditemukan');
  return { message: 'Akun Kepala Sekolah berhasil diperbarui' };
}

async function deleteKepsek(id) {
  const result = await kepsekModel.softDelete(id);
  if (result.affectedRows === 0) throw new HttpError(404, 'Akun Kepala Sekolah tidak ditemukan');
  return { message: 'Akun Kepala Sekolah dinonaktifkan' };
}


const UPLOADS_DIR = path.join(__dirname, '..', 'uploads');

function resolveUploadFilePath(fotoUrl) {
  if (!fotoUrl || !String(fotoUrl).startsWith('/uploads/')) return null;
  return path.join(UPLOADS_DIR, String(fotoUrl).replace('/uploads/', ''));
}

function unlinkQuiet(filePath) {
  if (!filePath) return;
  fs.unlink(filePath, () => {});
}

/** Upload / ganti foto profil Guru BK (username dari login). */
async function updateFotoGuru(username, file) {
  if (!username) throw new HttpError(400, 'Username wajib');
  if (!file) throw new HttpError(400, 'File foto wajib diunggah');

  const rows = await guruBkModel.findByUsername(username);
  if (rows.length === 0) {
    unlinkQuiet(file.path);
    throw new HttpError(404, 'Akun Guru BK tidak ditemukan');
  }

  const fotoPath = `/uploads/guru/${file.filename}`;
  await guruBkModel.updateFotoProfile(rows[0].id, fotoPath);

  unlinkQuiet(resolveUploadFilePath(rows[0].foto_profile));

  return {
    message: 'Foto profil berhasil diupdate',
    foto_profile: fotoPath,
  };
}

/** Hapus foto profil Guru BK. */
async function deleteFotoGuru(username) {
  if (!username) throw new HttpError(400, 'Username wajib');
  const rows = await guruBkModel.findByUsername(username);
  if (rows.length === 0) throw new HttpError(404, 'Akun Guru BK tidak ditemukan');

  await guruBkModel.clearFotoProfile(rows[0].id);
  unlinkQuiet(resolveUploadFilePath(rows[0].foto_profile));

  return { message: 'Foto profil berhasil dihapus' };
}

module.exports = {
  initAkunTables,
  loginGuru,
  loginKepsek,
  loginAdmin,
  listGuruPublic,
  listGuruAdmin,
  createGuru,
  updateGuru,
  deleteGuru,
  listKepsekAdmin,
  createKepsek,
  updateKepsek,
  deleteKepsek,
  updateFotoGuru,
  deleteFotoGuru,
};
