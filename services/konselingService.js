// services/konselingService.js
// Logika bisnis endpoint konseling (konfirmasi, notifikasi, laporan, walk-in).
const HttpError = require('../utils/HttpError');
const { kirimNotifikasiJadwal, kirimNotifikasiGuru } = require('./notifikasiDispatch');
const konselingModel = require('../models/konselingModel');
const siswaModel = require('../models/siswaModel');
const riwayatKelasModel = require('../models/riwayatKelasModel');
const guruBkModel = require('../models/guruBkModel');

/** Resolve username Guru BK dari nama (field konseling.guru_bk). */
async function resolveGuruUsernameByNama(namaGuru) {
  if (!namaGuru) return null;
  try {
    const rows = await guruBkModel.findByNama(namaGuru);
    if (rows.length > 0) return rows[0].username;
  } catch (e) {
    console.warn('Gagal resolve username guru dari nama:', e.message);
  }
  return null;
}

/** Migrasi kolom tabel konseling (idempotent). */
async function initMigrations() {
  const simple = [
    { sql: `ALTER TABLE konseling ADD COLUMN deskripsi TEXT NULL AFTER kategori`, label: 'deskripsi' },
    { sql: `ALTER TABLE konseling ADD COLUMN kelas_siswa VARCHAR(20) NULL AFTER deskripsi`, label: 'kelas_siswa' },
  ];
  for (const { sql, label } of simple) {
    try {
      await konselingModel.runAlter(sql);
      console.log(`✅ Kolom ${label} ditambahkan ke tabel konseling`);
    } catch (err) {
      if (err.code !== 'ER_DUP_FIELDNAME') {
        console.error(`❌ Error menambahkan kolom ${label}:`, err.message);
      }
    }
  }

  const laporanCols = [
    `ADD COLUMN laporan_tanggal DATE NULL AFTER laporan`,
    `ADD COLUMN laporan_waktu TIME NULL AFTER laporan_tanggal`,
    `ADD COLUMN laporan_dibuat_oleh VARCHAR(100) NULL AFTER laporan_waktu`,
    `ADD COLUMN laporan_kesimpulan TEXT NULL AFTER laporan_dibuat_oleh`,
    `ADD COLUMN laporan_rekomendasi TEXT NULL AFTER laporan_kesimpulan`,
    `ADD COLUMN laporan_status_penanganan VARCHAR(50) NULL AFTER laporan_rekomendasi`,
    `ADD COLUMN laporan_catatan_tambahan TEXT NULL AFTER laporan_status_penanganan`,
    `ADD COLUMN laporan_created_at TIMESTAMP NULL AFTER laporan_catatan_tambahan`,
  ];
  for (const clause of laporanCols) {
    try {
      await konselingModel.runAlter(`ALTER TABLE konseling ${clause}`);
    } catch (err) {
      if (err.code !== 'ER_DUP_FIELDNAME') {
        console.error('❌ Error migrasi kolom laporan:', clause, err.message);
      }
    }
  }
  console.log('✅ Kolom laporan terstruktur siap di tabel konseling');

  // --- Migrasi terminologi Validasi → Konfirmasi ---
  // 1) Rename kolom lama (jika masih pakai nama validasi)
  const renameCols = [
    ['status_validasi', 'status_konfirmasi'],
    ['tanggal_validasi', 'tanggal_konfirmasi'],
    ['jam_validasi', 'jam_konfirmasi'],
  ];
  for (const [oldName, newName] of renameCols) {
    try {
      await konselingModel.runAlter(
        `ALTER TABLE konseling CHANGE COLUMN \`${oldName}\` \`${newName}\` ${
          oldName === 'status_validasi'
            ? "VARCHAR(30) NOT NULL DEFAULT 'Belum Dikonfirmasi'"
            : oldName.startsWith('tanggal')
              ? 'DATE NULL DEFAULT NULL'
              : 'TIME NULL DEFAULT NULL'
        }`
      );
      console.log(`✅ Kolom ${oldName} diganti menjadi ${newName}`);
    } catch (err) {
      // ER_BAD_FIELD_ERROR = kolom lama tidak ada (sudah diganti / fresh install)
      if (err.code !== 'ER_BAD_FIELD_ERROR' && err.code !== 'ER_DUP_FIELDNAME') {
        // ignore if already renamed
      }
    }
  }

  // 2) Pastikan kolom baru ada (fresh install)
  const konfirmasiCols = [
    `ADD COLUMN status_konfirmasi VARCHAR(30) NOT NULL DEFAULT 'Belum Dikonfirmasi' AFTER status`,
    `ADD COLUMN tanggal_konfirmasi DATE NULL AFTER status_konfirmasi`,
    `ADD COLUMN jam_konfirmasi TIME NULL AFTER tanggal_konfirmasi`,
  ];
  for (const clause of konfirmasiCols) {
    try {
      await konselingModel.runAlter(`ALTER TABLE konseling ${clause}`);
    } catch (err) {
      if (err.code !== 'ER_DUP_FIELDNAME') {
        console.error('❌ Error migrasi kolom konfirmasi:', clause, err.message);
      }
    }
  }

  // 3) Samakan nilai status lama → baru
  try {
    await konselingModel.runAlter(
      `UPDATE konseling SET status_konfirmasi = 'Terkonfirmasi' WHERE status_konfirmasi IN ('Tervalidasi', 'tervalidasi')`
    );
    await konselingModel.runAlter(
      `UPDATE konseling SET status_konfirmasi = 'Belum Dikonfirmasi' WHERE status_konfirmasi IN ('Belum Divalidasi', 'belum divalidasi', '') OR status_konfirmasi IS NULL`
    );
  } catch (err) {
    console.warn('⚠️ Update nilai status_konfirmasi:', err.message);
  }
  console.log('✅ Kolom & nilai konfirmasi jadwal siap di tabel konseling');

  try {
    await konselingModel.runAlter(
      `ALTER TABLE konseling ADD COLUMN alasan_batal TEXT NULL AFTER status_konfirmasi`
    );
    console.log('✅ Kolom alasan_batal ditambahkan ke tabel konseling');
  } catch (err) {
    if (err.code !== 'ER_DUP_FIELDNAME') {
      console.error('❌ Error migrasi kolom alasan_batal:', err.message);
    }
  }

  // Sesi lanjutan: relasi ke pengajuan sebelumnya (nullable self-FK)
  try {
    await konselingModel.runAlter(
      `ALTER TABLE konseling ADD COLUMN pengajuan_sebelumnya_id INT NULL DEFAULT NULL`
    );
    console.log('✅ Kolom pengajuan_sebelumnya_id ditambahkan ke tabel konseling');
  } catch (err) {
    if (err.code !== 'ER_DUP_FIELDNAME') {
      console.error('❌ Error migrasi kolom pengajuan_sebelumnya_id:', err.message);
    }
  }

  // Index opsional untuk lookup anak
  try {
    await konselingModel.runAlter(
      `CREATE INDEX idx_konseling_parent ON konseling (pengajuan_sebelumnya_id)`
    );
    console.log('✅ Index idx_konseling_parent dibuat');
  } catch (err) {
    // ER_DUP_KEYNAME = index sudah ada
    if (err.code !== 'ER_DUP_KEYNAME' && err.code !== 'ER_DUP_FIELDNAME') {
      console.warn('⚠️ Index parent (boleh diabaikan):', err.message);
    }
  }

  // guru_id FK — relasi stabil ke akun Guru BK (nama bisa berubah)
  try {
    await konselingModel.runAlter(
      `ALTER TABLE konseling ADD COLUMN guru_id INT NULL DEFAULT NULL AFTER siswa_id`
    );
    console.log('✅ Kolom guru_id ditambahkan ke tabel konseling');
  } catch (err) {
    if (err.code !== 'ER_DUP_FIELDNAME') {
      console.error('❌ Error migrasi kolom guru_id:', err.message);
    }
  }
  try {
    await konselingModel.runAlter(
      `CREATE INDEX idx_konseling_guru_id ON konseling (guru_id)`
    );
  } catch (err) {
    if (err.code !== 'ER_DUP_KEYNAME' && err.code !== 'ER_DUP_FIELDNAME') {
      console.warn('⚠️ Index guru_id:', err.message);
    }
  }
  // Backfill dari nama (data lama)
  try {
    await konselingModel.runAlter(`
      UPDATE konseling k
      INNER JOIN guru_bk g ON g.nama = k.guru_bk
      SET k.guru_id = g.id
      WHERE k.guru_id IS NULL AND k.guru_bk IS NOT NULL AND k.guru_bk <> ''
    `);
    await konselingModel.runAlter(`
      UPDATE konseling k
      INNER JOIN guru_bk g ON LOWER(TRIM(g.nama)) = LOWER(TRIM(k.guru_bk))
      SET k.guru_id = g.id
      WHERE k.guru_id IS NULL AND k.guru_bk IS NOT NULL AND k.guru_bk <> ''
    `);
    console.log('✅ Backfill guru_id dari nama selesai');
  } catch (err) {
    console.warn('⚠️ Backfill guru_id:', err.message);
  }
}


async function resolveKelasSnapshot(nis, fallbackKelas) {
  let kelasSnapshot = fallbackKelas || '-';
  try {
    const kelasAktifRows = await riwayatKelasModel.findAktifByNis(nis);
    if (kelasAktifRows.length > 0) {
      kelasSnapshot = kelasAktifRows[0].kelas;
    }
  } catch (e) {
    console.warn('Gagal ambil kelas aktif dari riwayat_kelas, pakai siswa.kelas:', e.message);
  }
  return kelasSnapshot;
}


/** Pastikan user berhak mengakses/mengubah record konseling. */
function assertCanAccessKonseling(row, user, { mutate = false } = {}) {
  if (!user) throw new HttpError(401, 'Autentikasi diperlukan');
  if (user.role === 'admin' || user.role === 'kepsek') return;

  if (user.role === 'siswa') {
    const userNis = String(user.nis || '');
    const rowNis = String(row.nis || '');
    // juga cocokkan siswa_id jika ada
    if (rowNis && userNis && rowNis === userNis) return;
    if (row.siswa_id != null && user.id != null && Number(row.siswa_id) === Number(user.id)) return;
    throw new HttpError(403, 'Anda hanya dapat mengakses konseling milik sendiri');
  }

  if (user.role === 'guru') {
    // Prioritas: guru_id (stabil). Fallback: nama untuk data lama.
    if (user.id != null && row.guru_id != null && Number(user.id) === Number(row.guru_id)) {
      return;
    }
    const guruNama = String(user.nama || '').trim();
    const rowGuru = String(row.guru_bk || row.guru || '').trim();
    if (guruNama && rowGuru && guruNama === rowGuru) return;
    throw new HttpError(403, 'Anda hanya dapat mengakses konseling yang Anda tangani');
  }

  throw new HttpError(403, 'Akses ditolak');
}

/** POST /api/konseling — pengajuan baru oleh siswa. */
async function createPengajuan(body, user) {
  const { guru_bk, guru_username, guru_id: guruIdBody, tanggal, jam, jenis, kategori, deskripsi } = body;

  // NIS selalu dari JWT — siswa tidak boleh mengajukan atas nama orang lain
  if (!user || user.role !== 'siswa') {
    throw new HttpError(403, 'Hanya siswa yang dapat mengajukan konseling');
  }
  const nis = String(user.nis || '').trim();
  if (!nis) {
    throw new HttpError(401, 'Sesi siswa tidak valid');
  }

  if ((!guru_bk && !guruIdBody) || !tanggal || !jam || !jenis || !kategori || !deskripsi) {
    throw new HttpError(400, 'Semua field harus diisi (guru, jadwal, kategori, deskripsi)');
  }
  if (deskripsi.trim().length < 20) {
    throw new HttpError(400, 'Deskripsi minimal 20 karakter');
  }
  if (!['Luring', 'Daring'].includes(jenis)) {
    throw new HttpError(400, 'Jenis konseling tidak valid');
  }

  // Resolve Guru BK → guru_id stabil
  let resolvedGuru = null;
  if (guruIdBody) {
    const byId = await guruBkModel.findById(guruIdBody);
    if (byId.length) resolvedGuru = byId[0];
  }
  if (!resolvedGuru && guru_bk) {
    const byNama = await guruBkModel.findByNama(guru_bk);
    if (byNama.length) resolvedGuru = byNama[0];
  }
  if (!resolvedGuru) {
    throw new HttpError(400, 'Guru BK tidak ditemukan');
  }
  if (resolvedGuru.is_active === 0 || resolvedGuru.is_active === false) {
    throw new HttpError(400, 'Guru BK tidak aktif / tidak menerima pengajuan');
  }
  const guruId = resolvedGuru.id;
  const guruNamaResolved = resolvedGuru.nama;

  const siswaRows = await siswaModel.findIdAndKelasByNis(nis);
  if (siswaRows.length === 0) {
    throw new HttpError(404, 'Siswa tidak ditemukan');
  }
  const siswaId = siswaRows[0].id;
  const kelasSnapshot = await resolveKelasSnapshot(nis, siswaRows[0].kelas);

  const result = await konselingModel.insertPengajuan({
    siswaId,
    guru_id: guruId,
    guru_bk: guruNamaResolved,
    tanggal, jam, jenis, kategori,
    deskripsi: deskripsi.trim(), kelasSnapshot,
  });

  // Notifikasi ke Guru BK: pengajuan baru
  try {
    let guruUsername = (guru_username && String(guru_username).trim()) || resolvedGuru.username || null;
    if (!guruUsername) {
      guruUsername = await resolveGuruUsernameByNama(guruNamaResolved);
    }
    console.log(
      `ℹ️  [notif-guru] pengajuan id=${result.insertId} guru_bk="${guru_bk}" username=${guruUsername || '(tidak ketemu)'}`
    );
    const namaSiswa = siswaRows[0].nama || nis;
    await kirimNotifikasiGuru({
      guruUsername,
      konselingId: result.insertId,
      tipe: 'pengajuan',
      judul: 'Pengajuan Konseling Baru',
      pesan: `${namaSiswa} (NIS ${nis}) mengajukan konseling ${jenis} — kategori ${kategori} pada ${tanggal} pukul ${jam}.`,
    });
  } catch (e) {
    console.warn('Gagal kirim notifikasi pengajuan ke guru:', e.message);
  }

  return {
    message: 'Pengajuan konseling berhasil disimpan',
    id: result.insertId,
  };
}

/** GET /api/konseling-all — semua sesi (dashboard kepsek). */
async function listAll() {
  return konselingModel.listAll();
}

/** GET /api/konseling-bk — sesi milik Guru BK yang login (nama dari JWT). */
async function listByGuru(guruFromQuery, user) {
  if (user && user.role === 'guru') {
    // Selalu dari JWT — jangan percaya query client
    return konselingModel.listByGuru({
      guruId: user.id,
      guruNama: user.nama,
    });
  }
  // Admin / kepsek boleh filter by nama dari query
  if (!guruFromQuery) {
    throw new HttpError(400, 'Parameter guru wajib diisi');
  }
  return konselingModel.listByGuru({ guruNama: guruFromQuery });
}

/** PUT /api/konseling/:id/konfirmasi — tetapkan/ubah jadwal + notifikasi. */
async function konfirmasi(id, { tanggal, jam }, user) {
  if (!tanggal || !jam) {
    throw new HttpError(400, 'Tanggal dan jam konfirmasi wajib diisi');
  }

  const existingRows = await konselingModel.findForKonfirmasi(id);
  if (existingRows.length === 0) {
    throw new HttpError(404, 'Data konseling tidak ditemukan');
  }
  const existing = existingRows[0];
  assertCanAccessKonseling(existing, user, { mutate: true });

  // Guard: tidak boleh konfirmasi sesi yang sudah Selesai / Dibatalkan
  if (existing.status !== 'Proses') {
    throw new HttpError(
      400,
      `Konseling berstatus "${existing.status}" tidak dapat dikonfirmasi. Hanya pengajuan berstatus Proses yang boleh dikonfirmasi atau diubah jadwalnya.`
    );
  }

  // Cegah double-booking slot guru
  const bentrok = await konselingModel.countJadwalBentrok({
    guru_id: existing.guru_id,
    guru_bk: existing.guru_bk,
    tanggal,
    jam,
    excludeId: id,
  });
  if (bentrok > 0) {
    throw new HttpError(409, 'Jadwal bentrok dengan sesi konseling lain pada tanggal/jam yang sama');
  }

  const result = await konselingModel.updateKonfirmasi(id, { tanggal, jam });
  if (result.affectedRows === 0) {
    throw new HttpError(400, 'Konfirmasi gagal. Pastikan status konseling masih Proses.');
  }

  const sudahTerkonfirmasi = existing.status_konfirmasi === 'Terkonfirmasi';
  const jadwalBerubah = existing.tanggalLama !== tanggal || existing.jamLama !== jam;

  if (sudahTerkonfirmasi && jadwalBerubah) {
    await kirimNotifikasiJadwal({
      siswaId: existing.siswa_id,
      konselingId: id,
      judul: 'Jadwal Konseling Diubah',
      pesan: `Guru BK mengubah jadwal konseling Anda dari ${existing.tanggalLama} pukul ${existing.jamLama} menjadi ${tanggal} pukul ${jam}.`,
      tanggalLama: existing.tanggalLama,
      jamLama: existing.jamLama,
      tanggalBaru: tanggal,
      jamBaru: jam,
    });
  } else if (!sudahTerkonfirmasi) {
    await kirimNotifikasiJadwal({
      siswaId: existing.siswa_id,
      konselingId: id,
      judul: 'Jadwal Konseling Ditetapkan',
      pesan: `Guru BK telah menetapkan jadwal konseling Anda pada ${tanggal} pukul ${jam}.`,
      tanggalBaru: tanggal,
      jamBaru: jam,
    });
  }

  return { message: 'Jadwal berhasil dikonfirmasi' };
}

/** PUT /api/konseling/:id/status — ubah status (mis. Dibatalkan). */
async function updateStatus(id, status, user) {
  // Hanya izinkan pembatalan lewat endpoint ini — Selesai harus lewat laporan
  if (!['Dibatalkan'].includes(status)) {
    throw new HttpError(400, 'Status tidak valid. Gunakan endpoint laporan untuk menyelesaikan sesi.');
  }

  const existingRows = await konselingModel.findForStatus(id);
  if (existingRows.length === 0) {
    throw new HttpError(404, 'Data konseling tidak ditemukan');
  }
  const existing = existingRows[0];
  assertCanAccessKonseling(existing, user, { mutate: true });

  // Guard: status final tidak boleh diubah lagi
  if (existing.status === 'Selesai' || existing.status === 'Dibatalkan') {
    throw new HttpError(
      400,
      `Status "${existing.status}" bersifat final dan tidak dapat diubah lagi.`
    );
  }

  if (status === existing.status) {
    return { message: 'Status tidak berubah' };
  }

  const result = await konselingModel.updateStatus(id, status);
  if (result.affectedRows === 0) {
    throw new HttpError(400, 'Gagal mengubah status. Pastikan status masih Proses.');
  }

  if (status === 'Dibatalkan') {
    await kirimNotifikasiJadwal({
      siswaId: existing.siswa_id,
      konselingId: id,
      judul: 'Jadwal Konseling Dibatalkan',
      pesan: `Guru BK membatalkan jadwal konseling Anda pada ${existing.tanggal} pukul ${existing.jam}.`,
      tanggalLama: existing.tanggal,
      jamLama: existing.jam,
    });
  }

  return { message: 'Status berhasil diubah' };
}

/** PUT /api/konseling/:id/laporan — simpan laporan & set status Selesai. */
const LAPORAN_EDIT_WINDOW_HOURS = 72; // 3 x 24 jam

async function simpanLaporan(id, body, user) {
  const { kesimpulan, rekomendasi, statusPenanganan, catatanTambahan } = body;
  if (!kesimpulan || !rekomendasi) {
    throw new HttpError(400, 'Kesimpulan dan rekomendasi wajib diisi');
  }

  // Ownership: guru hanya boleh laporan konseling miliknya
  const ownRows = await konselingModel.findForStatus(id);
  if (ownRows.length === 0) {
    throw new HttpError(404, 'Data konseling tidak ditemukan');
  }
  assertCanAccessKonseling(ownRows[0], user, { mutate: true });

  // Identitas pembuat dari JWT, bukan body client
  const dibuatOleh = (user && (user.nama || user.username)) || 'Guru BK';

  const rows = await konselingModel.findLaporanCreatedAt(id);
  if (rows.length === 0) {
    throw new HttpError(404, 'Data konseling tidak ditemukan');
  }

  const sudahPernahDisimpan = !!rows[0].laporan_created_at;

  if (sudahPernahDisimpan) {
    const createdAt = new Date(rows[0].laporan_created_at);
    const jamBerlalu = (Date.now() - createdAt.getTime()) / (1000 * 60 * 60);
    if (jamBerlalu > LAPORAN_EDIT_WINDOW_HOURS) {
      throw new HttpError(
        403,
        `Laporan ini sudah terkunci. Batas edit adalah ${LAPORAN_EDIT_WINDOW_HOURS} jam setelah pertama kali disimpan, dan itu sudah lewat.`
      );
    }

    await konselingModel.updateLaporanEdit(id, {
      kesimpulan: kesimpulan.trim(),
      rekomendasi: rekomendasi.trim(),
      statusPenanganan: statusPenanganan || 'Selesai - Masalah Teratasi',
      catatanTambahan: (catatanTambahan || '').trim() || '-',
    });
    return { message: 'Laporan berhasil diperbarui', edited: true };
  }

  const firstResult = await konselingModel.updateLaporanFirst(id, {
    kesimpulan: kesimpulan.trim(),
    rekomendasi: rekomendasi.trim(),
    statusPenanganan: statusPenanganan || 'Selesai - Masalah Teratasi',
    catatanTambahan: (catatanTambahan || '').trim() || '-',
    dibuatOleh,
  });
  if (!firstResult || firstResult.affectedRows === 0) {
    throw new HttpError(
      400,
      'Laporan hanya dapat disimpan untuk sesi berstatus Proses yang sudah dikonfirmasi'
    );
  }
  return { message: 'Laporan berhasil disimpan', edited: false };
}

/** POST /api/konseling/walkin — input manual Guru BK. */
async function createWalkin(body, user) {
  const { nis, tanggal, jam, jenis, kategori, deskripsi, catatan } = body;
  const guru_bk = (user && user.role === 'guru' && user.nama) ? user.nama : body.guru_bk;
  if (user && user.role === 'guru' && body.guru_bk && String(body.guru_bk) !== String(user.nama)) {
    throw new HttpError(403, 'Anda tidak dapat mencatat walk-in atas nama guru lain');
  }
  if (!nis || !guru_bk || !tanggal || !jam || !jenis || !kategori || !deskripsi) {
    throw new HttpError(400, 'Semua field wajib diisi');
  }

  const siswaRows = await siswaModel.findIdAndKelasByNis(nis);
  if (siswaRows.length === 0) {
    throw new HttpError(404, 'Siswa dengan NIS tersebut belum terdaftar. Daftarkan akun siswa terlebih dahulu.');
  }
  const siswaId = siswaRows[0].id;

  let kelasSnapshot = siswaRows[0].kelas || '-';
  try {
    const kelasAktifRows = await riwayatKelasModel.findAktifByNis(nis);
    if (kelasAktifRows.length > 0) kelasSnapshot = kelasAktifRows[0].kelas;
  } catch (e) {
    console.warn('Gagal ambil kelas aktif untuk walk-in, pakai siswa.kelas:', e.message);
  }

  // Deskripsi tetap murni; catatan walk-in disimpan di kolom khusus
  const deskripsiClean = deskripsi.trim();
  const catatanWalkin = (catatan && String(catatan).trim()) || null;

  const result = await konselingModel.insertWalkin({
    siswaId,
    guru_id: (user && user.role === 'guru') ? user.id : null,
    guru_bk,
    tanggal,
    jam,
    jenis,
    kategori,
    deskripsi: deskripsiClean,
    kelasSnapshot,
    catatanWalkin,
  });

  return {
    message: 'Data konseling walk-in berhasil disimpan',
    id: result.insertId,
  };
}

/** DELETE /api/konseling/:id — batalkan pengajuan (hanya status Proses). Hard delete untuk "Konsul Ulang". */
async function batalkan(id, user) {
  // Gunakan data lengkap untuk ownership
  const rows = await konselingModel.findForStatus(id);
  if (rows.length === 0) {
    throw new HttpError(404, 'Data konseling tidak ditemukan');
  }
  assertCanAccessKonseling(rows[0], user, { mutate: true });
  if (rows[0].status !== 'Proses') {
    throw new HttpError(400, 'Hanya pengajuan berstatus Proses yang bisa dibatalkan');
  }
  // Siswa: soft-cancel lebih aman via batalkanOlehSiswa. Hard delete hanya staff.
  if (user && user.role === 'siswa') {
    throw new HttpError(
      400,
      'Siswa harus membatalkan lewat endpoint batal-siswa (dengan alasan)'
    );
  }
  await konselingModel.deleteById(id);
  return { message: 'Pengajuan konseling berhasil dibatalkan' };
}

/**
 * PUT /api/konseling/:id/batal-siswa — soft cancel oleh siswa dari Detail Riwayat.
 * Hanya status Proses, wajib alasan, hanya pemilik data.
 */
async function batalkanOlehSiswa(id, { alasan }, user) {
  const alasanTrim = (alasan || '').trim();
  if (alasanTrim.length < 10) {
    throw new HttpError(400, 'Alasan pembatalan minimal 10 karakter');
  }

  const rows = await konselingModel.findForBatalkanSiswa(id);
  if (rows.length === 0) {
    throw new HttpError(404, 'Data konseling tidak ditemukan');
  }
  const existing = rows[0];

  if (existing.status !== 'Proses') {
    throw new HttpError(400, 'Hanya pengajuan berstatus Proses yang bisa dibatalkan');
  }

  // Ownership: siswa hanya boleh batalkan milik sendiri
  if (user?.role === 'siswa') {
    const userNis = user.nis != null ? String(user.nis) : null;
    if (!userNis || userNis !== String(existing.nis)) {
      throw new HttpError(403, 'Anda hanya dapat membatalkan pengajuan milik sendiri');
    }
  }

  const result = await konselingModel.updateBatalkanSiswa(id, alasanTrim);
  if (result.affectedRows === 0) {
    throw new HttpError(400, 'Pengajuan tidak dapat dibatalkan (mungkin status sudah berubah)');
  }

  // Notifikasi ke Guru BK: siswa membatalkan
  try {
    const guruUsername = await resolveGuruUsernameByNama(existing.guru_bk);
    await kirimNotifikasiGuru({
      guruUsername,
      konselingId: id,
      tipe: 'pembatalan',
      judul: 'Pengajuan Konseling Dibatalkan Siswa',
      pesan: `${existing.nama_siswa || existing.nis} (NIS ${existing.nis}) membatalkan pengajuan konseling pada ${existing.tanggal} pukul ${existing.jam}. Alasan: ${alasanTrim}`,
    });
  } catch (e) {
    console.warn('Gagal kirim notifikasi pembatalan ke guru:', e.message);
  }

  return {
    message: 'Pengajuan konseling berhasil dibatalkan',
    alasan: alasanTrim,
  };
}


/**
 * POST /api/konseling/lanjutan
 * Guru BK membuat pengajuan sesi lanjutan dari sesi yang sudah selesai
 * dengan status penanganan Monitoring (atau secara eksplisit).
 * Relasi: pengajuan_sebelumnya_id = id sesi induk.
 */
async function createLanjutan(body, user) {
  const {
    pengajuan_sebelumnya_id,
    tanggal,
    jam,
    jenis,
    kategori,
    deskripsi,
    guru_bk,
  } = body || {};

  const parentId = parseInt(pengajuan_sebelumnya_id, 10);
  if (!parentId || Number.isNaN(parentId)) {
    throw new HttpError(400, 'pengajuan_sebelumnya_id wajib diisi');
  }
  if (!tanggal || !jam) {
    throw new HttpError(400, 'Tanggal dan jam sesi lanjutan wajib diisi');
  }

  const parentRows = await konselingModel.findByIdForLanjutan(parentId);
  if (parentRows.length === 0) {
    throw new HttpError(404, 'Sesi sebelumnya tidak ditemukan');
  }
  const parent = parentRows[0];
  assertCanAccessKonseling(parent, user, { mutate: true });

  // Hanya boleh dari sesi yang sudah Selesai (laporan sudah ada)
  if (parent.status !== 'Selesai') {
    throw new HttpError(
      400,
      `Sesi lanjutan hanya bisa dibuat dari konseling berstatus Selesai (saat ini: ${parent.status})`
    );
  }

  const jenisFinal = jenis && ['Luring', 'Daring'].includes(jenis) ? jenis : (parent.jenis || 'Luring');
  const kategoriFinal = (kategori && String(kategori).trim()) || parent.kategori || 'Lainnya';
  const deskripsiFinal = (deskripsi && String(deskripsi).trim())
    || `Sesi lanjutan dari konseling #${parentId}. ${parent.deskripsi ? parent.deskripsi.substring(0, 200) : ''}`.trim();
  // Guru yang login = penanggung jawab (id + nama snapshot)
  let guruIdFinal = parent.guru_id || null;
  let guruFinal = parent.guru_bk;
  if (user && user.role === 'guru') {
    guruIdFinal = user.id;
    guruFinal = user.nama || guruFinal;
  } else if (guru_bk && String(guru_bk).trim()) {
    guruFinal = String(guru_bk).trim();
  }

  if (deskripsiFinal.length < 20) {
    throw new HttpError(400, 'Deskripsi minimal 20 karakter');
  }

  const result = await konselingModel.insertPengajuan({
    siswaId: parent.siswa_id,
    guru_id: guruIdFinal,
    guru_bk: guruFinal,
    tanggal,
    jam,
    jenis: jenisFinal,
    kategori: kategoriFinal,
    deskripsi: deskripsiFinal,
    kelasSnapshot: parent.kelas_siswa || '-',
    pengajuan_sebelumnya_id: parentId,
  });

  // Notifikasi ke siswa: sesi lanjutan telah dibuat oleh Guru BK
  try {
    await kirimNotifikasiJadwal({
      siswaId: parent.siswa_id,
      konselingId: result.insertId,
      judul: 'Sesi Konseling Lanjutan',
      pesan: `Guru BK menjadwalkan sesi lanjutan pada ${tanggal} pukul ${jam} (lanjutan dari sesi #${parentId}). Silakan cek detail di riwayat konseling.`,
      tanggalBaru: tanggal,
      jamBaru: jam,
    });
  } catch (e) {
    console.warn('Gagal kirim notifikasi sesi lanjutan ke siswa:', e.message);
  }

  return {
    message: 'Pengajuan sesi lanjutan berhasil dibuat',
    id: result.insertId,
    pengajuan_sebelumnya_id: parentId,
  };
}

/** GET /api/konseling/:nis — riwayat milik satu siswa. */
async function listByNis(nis) {
  const siswaRows = await siswaModel.findIdOnlyByNis(nis);
  if (siswaRows.length === 0) {
    throw new HttpError(404, 'Siswa tidak ditemukan');
  }
  return konselingModel.listBySiswaId(siswaRows[0].id);
}

/** GET /api/konseling/detail/:id — termasuk info parent & anak (rantai sesi). */
async function getDetail(id, user) {
  const rows = await konselingModel.findDetailById(id);
  if (rows.length === 0) {
    throw new HttpError(404, 'Data konseling tidak ditemukan');
  }
  const row = rows[0];
  assertCanAccessKonseling(row, user, { mutate: false });
  const parent = row.pengajuan_sebelumnya_id
    ? await konselingModel.findParentBrief(row.pengajuan_sebelumnya_id)
    : null;
  const children = await konselingModel.findChildrenByParentId(id);
  return {
    ...row,
    sesi_sebelumnya: parent,
    sesi_lanjutan: children,
  };
}

module.exports = {
  initMigrations,
  createPengajuan,
  listAll,
  listByGuru,
  konfirmasi,
  updateStatus,
  simpanLaporan,
  createWalkin,
  batalkan,
  batalkanOlehSiswa,
  createLanjutan,
  listByNis,
  getDetail,
};
