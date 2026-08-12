// services/notifikasiDispatch.js
// Helper kirim notifikasi jadwal (DB + Socket.IO + Web Push).
// Dipakai konselingService; dependency realtime di-inject dari server.js via configure().
const notifikasiModel = require('../models/notifikasiModel');
const siswaModel = require('../models/siswaModel');

let io = null;
let webpush = null;
let VAPID_PUBLIC_KEY = '';
let VAPID_PRIVATE_KEY = '';

function configure(deps) {
  io = deps.io || null;
  webpush = deps.webpush || null;
  VAPID_PUBLIC_KEY = deps.VAPID_PUBLIC_KEY || '';
  VAPID_PRIVATE_KEY = deps.VAPID_PRIVATE_KEY || '';
}

async function kirimPushKeSiswa(siswaId, { title, body, data }) {
  if (!webpush || !VAPID_PUBLIC_KEY || !VAPID_PRIVATE_KEY) {
    console.log(`ℹ️  [push] Dilewati untuk siswa_id=${siswaId} — web-push belum tersedia/dikonfigurasi.`);
    return;
  }

  try {
    const subs = await notifikasiModel.listPushBySiswaId(siswaId);

    console.log(`ℹ️  [push] siswa_id=${siswaId} punya ${subs.length} subscription terdaftar.`);
    if (subs.length === 0) {
      console.log(`⚠️  [push] Tidak ada subscription untuk siswa_id=${siswaId} — siswa ini belum pernah klik "Aktifkan notifikasi push" di browser/device-nya sendiri, jadi push TIDAK akan sampai ke dia (walau notifikasi tetap tersimpan & tampil real-time di dalam app).`);
    }

    const payloadString = JSON.stringify({ title, body, data });

    await Promise.all(subs.map(async (sub) => {
      const pushSubscription = {
        endpoint: sub.endpoint,
        keys: { p256dh: sub.p256dh, auth: sub.auth },
      };
      try {
        await webpush.sendNotification(pushSubscription, payloadString);
        console.log(`✅ [push] Terkirim ke subscription id=${sub.id} (siswa_id=${siswaId}).`);
      } catch (err) {
        if (err.statusCode === 404 || err.statusCode === 410) {
          console.log(`⚠️  [push] Subscription id=${sub.id} sudah kadaluarsa, dihapus dari database.`);
          await notifikasiModel.deletePushById(sub.id);
        } else {
          console.error(`❌ [push] Gagal mengirim ke subscription id=${sub.id}:`, err.message);
        }
      }
    }));
  } catch (err) {
    console.error('❌ Error kirimPushKeSiswa:', err.message);
  }
}

async function kirimNotifikasiJadwal({
  siswaId,
  konselingId,
  judul,
  pesan,
  tanggalLama,
  jamLama,
  tanggalBaru,
  jamBaru,
}) {
  try {
    const result = await notifikasiModel.insertJadwal({
      siswaId,
      konselingId,
      judul,
      pesan,
      tanggalLama,
      jamLama,
      tanggalBaru,
      jamBaru,
    });

    const payload = {
      id: result.insertId,
      konselingId: konselingId || null,
      tipe: 'jadwal',
      judul,
      pesan,
      tanggalLama: tanggalLama || null,
      jamLama: jamLama || null,
      tanggalBaru: tanggalBaru || null,
      jamBaru: jamBaru || null,
      isRead: false,
      createdAt: new Date().toISOString(),
    };

    if (io) {
      const siswaRows = await siswaModel.findNisById(siswaId);
      if (siswaRows.length > 0) {
        const room = `siswa-notif-${siswaRows[0].nis}`;
        const socketsDiRoom = await io.in(room).fetchSockets();
        console.log(`ℹ️  [realtime] Emit ke room "${room}" — ${socketsDiRoom.length} koneksi aktif sedang join room ini.`);
        io.to(room).emit('notifikasi-baru', payload);
      } else {
        console.log(`⚠️  [realtime] siswa_id=${siswaId} tidak ditemukan di tabel siswa — notifikasi tidak bisa dikirim real-time.`);
      }
    }

    await kirimPushKeSiswa(siswaId, { title: judul, body: pesan, data: payload });
  } catch (err) {
    console.error('❌ Error kirimNotifikasiJadwal:', err.message);
  }
}

/** Kunci publik VAPID untuk frontend pushManager.subscribe */
function getVapidPublicKey() {
  return VAPID_PUBLIC_KEY || '';
}

/** True jika package web-push berhasil di-require (sama seperti cek di server.js lama). */
function isWebPushPackageLoaded() {
  return !!webpush;
}

/**
 * Notifikasi ke Guru BK (DB + Socket.IO realtime).
 * Room: guru-notif-{username}
 */
async function kirimNotifikasiGuru({
  guruUsername,
  konselingId,
  tipe,
  judul,
  pesan,
}) {
  if (!guruUsername) {
    console.log('⚠️  [notif-guru] Dilewati — guruUsername kosong');
    return;
  }

  try {
    const result = await notifikasiModel.insertGuru({
      guruUsername,
      konselingId,
      tipe: tipe || 'pengajuan',
      judul,
      pesan,
    });

    const payload = {
      id: result.insertId,
      konselingId: konselingId || null,
      tipe: tipe || 'pengajuan',
      judul,
      pesan,
      isRead: false,
      createdAt: new Date().toISOString(),
    };

    if (io) {
      const room = `guru-notif-${guruUsername}`;
      const socketsDiRoom = await io.in(room).fetchSockets();
      console.log(`ℹ️  [realtime] Emit ke room "${room}" — ${socketsDiRoom.length} koneksi aktif.`);
      io.to(room).emit('notifikasi-guru-baru', payload);
    }
  } catch (err) {
    console.error('❌ Error kirimNotifikasiGuru:', err.message);
  }
}

module.exports = {
  configure,
  kirimNotifikasiJadwal,
  kirimNotifikasiGuru,
  kirimPushKeSiswa,
  getVapidPublicKey,
  isWebPushPackageLoaded,
};
