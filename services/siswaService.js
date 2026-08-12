// services/siswaService.js
// Logika bisnis data siswa (CRUD manual, import Excel, preview absen).
const XLSX = require('xlsx');
const HttpError = require('../utils/HttpError');
const siswaModel = require('../models/siswaModel');

const VALID_KELAS_LIST = [
  'X - 1', 'X - 2', 'X - 3', 'X - 4', 'X - 5', 'X - 6', 'X - 7', 'X - 8', 'X - 9', 'X - 10',
  'XI - 1', 'XI - 2', 'XI - 3', 'XI - 4', 'XI - 5', 'XI - 6', 'XI - 7', 'XI - 8', 'XI - 9', 'XI - 10',
  'XII - 1', 'XII - 2', 'XII - 3', 'XII - 4', 'XII - 5', 'XII - 6', 'XII - 7', 'XII - 8', 'XII - 9', 'XII - 10',
];

function normalizeJenisKelamin(val) {
  if (!val) return null;
  const v = String(val).trim().toLowerCase();
  if (['l', 'laki-laki', 'laki laki', 'pria', 'male'].includes(v)) return 'Laki-laki';
  if (['p', 'perempuan', 'wanita', 'female'].includes(v)) return 'Perempuan';
  return null;
}

/** Upsert satu baris siswa. Return 'inserted' | 'updated'. */
async function upsertSatuSiswa(nis, nama, kelas, jenis_kelamin) {
  const jk = normalizeJenisKelamin(jenis_kelamin);
  const existing = await siswaModel.findIdByNis(nis);
  if (existing.length > 0) {
    await siswaModel.updateBasicByNis(nis, { nama, kelas, jenis_kelamin: jk });
    return 'updated';
  }
  await siswaModel.insertSiswa({
    nis, nama, kelas, jenis_kelamin: jk, password: nis,
  });
  return 'inserted';
}

/** Tambah satu siswa manual (password default = NIS). */
async function createSiswa({ nis, nama, kelas, jenis_kelamin }) {
  if (!nis || !nama || !kelas) {
    throw new HttpError(400, 'NIS, nama, dan kelas wajib diisi');
  }
  if (!/^[0-9]+$/.test(String(nis))) {
    throw new HttpError(400, 'NIS hanya boleh berupa angka');
  }
  if (!VALID_KELAS_LIST.includes(kelas)) {
    throw new HttpError(400, 'Kelas tidak valid');
  }

  const jk = normalizeJenisKelamin(jenis_kelamin) || null;

  const existing = await siswaModel.findIdByNis(nis);
  if (existing.length > 0) {
    throw new HttpError(400, 'NIS sudah terdaftar');
  }

  await siswaModel.insertSiswa({
    nis, nama, kelas, jenis_kelamin: jk, password: String(nis),
  });

  return { message: 'Siswa berhasil ditambahkan. Password default: NIS siswa.' };
}

/** Daftar semua siswa + status kelas aktif (riwayat_kelas). */
async function listSiswa() {
  return siswaModel.listAllWithKelasAktif();
}

/**
 * Import siswa dari buffer file Excel.
 * Kolom (case-insensitive): NIS, Nama, Kelas, Jenis Kelamin.
 * NIS yang sudah ada di-UPDATE, bukan ditolak.
 */
async function importFromExcel(buffer) {
  let rows;
  try {
    const workbook = XLSX.read(buffer, { type: 'buffer' });
    const sheet = workbook.Sheets[workbook.SheetNames[0]];
    rows = XLSX.utils.sheet_to_json(sheet, { defval: '' });
  } catch (e) {
    throw new HttpError(400, 'Gagal membaca file Excel. Pastikan formatnya .xlsx atau .xls');
  }

  if (!rows || rows.length === 0) {
    throw new HttpError(400, 'File Excel kosong atau tidak punya baris data');
  }

  let inserted = 0;
  let updated = 0;
  const skipped = [];

  for (let i = 0; i < rows.length; i++) {
    const rowNum = i + 2; // baris 1 = header
    const raw = rows[i];

    const keyMap = {};
    Object.keys(raw).forEach((k) => {
      keyMap[k.trim().toLowerCase()] = raw[k];
    });

    const nis = String(keyMap.nis || '').trim();
    const nama = String(keyMap.nama || '').trim();
    const kelas = String(keyMap.kelas || '').trim();
    const jk = keyMap['jenis kelamin'] || keyMap.jenis_kelamin || keyMap.jk;

    if (!nis || !/^[0-9]+$/.test(nis)) {
      skipped.push({ row: rowNum, reason: 'NIS kosong atau bukan angka' });
      continue;
    }
    if (!nama) {
      skipped.push({ row: rowNum, reason: 'Nama kosong' });
      continue;
    }
    if (!VALID_KELAS_LIST.includes(kelas)) {
      skipped.push({ row: rowNum, reason: `Kelas "${kelas}" tidak valid` });
      continue;
    }

    try {
      const result = await upsertSatuSiswa(nis, nama, kelas, jk);
      if (result === 'updated') updated += 1;
      else inserted += 1;
    } catch (e) {
      skipped.push({ row: rowNum, reason: 'Gagal menyimpan: ' + e.message });
    }
  }

  return {
    message: `Import selesai — ${inserted} siswa baru ditambahkan, ${updated} siswa diperbarui, ${skipped.length} baris dilewati.`,
    inserted,
    updated,
    skipped,
  };
}

/**
 * Preview file "Daftar Hadir" (absen).
 * Sheet bernama X / XI / XII, blok per kelas ("KELAS X - 1", lalu No/NIS/Nama/L-P).
 * Tidak menulis ke DB — hanya parse & kembalikan sections.
 */
function previewAbsen(buffer) {
  let workbook;
  try {
    workbook = XLSX.read(buffer, { type: 'buffer' });
  } catch (e) {
    throw new HttpError(400, 'Gagal membaca file Excel. Pastikan formatnya .xlsx atau .xls');
  }

  const targetSheets = ['X', 'XI', 'XII'].filter((name) => workbook.SheetNames.includes(name));
  if (targetSheets.length === 0) {
    throw new HttpError(400, 'Sheet "X", "XI", atau "XII" tidak ditemukan di file ini');
  }

  const sections = [];

  targetSheets.forEach((sheetName) => {
    const sheet = workbook.Sheets[sheetName];
    const grid = XLSX.utils.sheet_to_json(sheet, { header: 1, defval: '' });

    let current = null;
    grid.forEach((row) => {
      const c0 = row[0];
      const c1 = row[1];
      const c2 = row[2];
      const c3 = row[3];

      if (typeof c0 === 'string' && c0.toUpperCase().includes('KELAS')) {
        current = { sheet: sheetName, label: c0.trim(), siswa: [] };
        sections.push(current);
        return;
      }

      const isNoAngka = typeof c0 === 'number';
      const nisOk = c1 !== '' && c1 !== null && c1 !== undefined;
      const namaOk = typeof c2 === 'string' && c2.trim() !== '';
      const jkOk = c3 === 'L' || c3 === 'P';

      if (current && isNoAngka && nisOk && namaOk && jkOk) {
        current.siswa.push({
          nis: String(c1).trim(),
          nama: c2.trim(),
          jk: c3,
        });
      }
    });
  });

  const totalSiswa = sections.reduce((sum, s) => sum + s.siswa.length, 0);

  return {
    sections,
    totalSiswa,
    message: `Ditemukan ${sections.length} kelas dengan total ${totalSiswa} siswa di sheet ${targetSheets.join(', ')}.`,
  };
}

/**
 * Konfirmasi hasil mapping absen → simpan ke DB.
 * body.rows: [{ nis, nama, kelas, jenis_kelamin }, ...]
 */
async function importRows(rows) {
  if (!Array.isArray(rows) || rows.length === 0) {
    throw new HttpError(400, 'Tidak ada baris siswa untuk diimport');
  }

  let inserted = 0;
  let updated = 0;
  const skipped = [];

  for (let i = 0; i < rows.length; i++) {
    const r = rows[i];
    const nis = String(r.nis || '').trim();
    const nama = String(r.nama || '').trim();
    const kelas = String(r.kelas || '').trim();

    if (!nis || !/^[0-9]+$/.test(nis)) {
      skipped.push({ row: i + 1, reason: `NIS "${nis}" tidak valid (${nama || 'tanpa nama'})` });
      continue;
    }
    if (!nama) {
      skipped.push({ row: i + 1, reason: `Nama kosong (NIS ${nis})` });
      continue;
    }
    if (!VALID_KELAS_LIST.includes(kelas)) {
      skipped.push({ row: i + 1, reason: `Kelas "${kelas}" tidak valid (${nama})` });
      continue;
    }

    try {
      const result = await upsertSatuSiswa(nis, nama, kelas, r.jenis_kelamin);
      if (result === 'updated') updated += 1;
      else inserted += 1;
    } catch (e) {
      skipped.push({ row: i + 1, reason: `Gagal menyimpan ${nama}: ` + e.message });
    }
  }

  return {
    message: `Import selesai — ${inserted} siswa baru ditambahkan, ${updated} siswa diperbarui, ${skipped.length} baris dilewati.`,
    inserted,
    updated,
    skipped,
  };
}

module.exports = {
  VALID_KELAS_LIST,
  normalizeJenisKelamin,
  createSiswa,
  listSiswa,
  importFromExcel,
  previewAbsen,
  importRows,
};
