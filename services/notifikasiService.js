// services/notifikasiService.js
// HTTP API notifikasi + push subscription. Logika kirim (dispatch) tetap di
// notifikasiDispatch.js agar perilaku Socket.IO + Web Push tidak berubah.
const HttpError = require('../utils/HttpError');
const {
  getVapidPublicKey,
  isWebPushPackageLoaded,
} = require('./notifikasiDispatch');
const notifikasiModel = require('../models/notifikasiModel');
const siswaModel = require('../models/siswaModel');

/** Pastikan tabel notifikasi & push_subscriptions ada (idempotent). */
async function initTables() {
  try {
    await notifikasiModel.ensureNotifikasiTable();
    console.log('✅ Tabel notifikasi siap');
  } catch (err) {
    console.error('❌ Error membuat tabel notifikasi:', err.message);
  }

  try {
    await notifikasiModel.ensurePushSubscriptionsTable();
    console.log('✅ Tabel push_subscriptions siap');
  } catch (err) {
    console.error('❌ Error membuat tabel push_subscriptions:', err.message);
  }

  try {
    await notifikasiModel.ensureNotifikasiGuruTable();
    console.log('✅ Tabel notifikasi_guru siap');
  } catch (err) {
    console.error('❌ Error membuat tabel notifikasi_guru:', err.message);
  }
}

/** GET kunci publik VAPID — sama seperti handler lama. */
function getVapidKey() {
  const publicKey = getVapidPublicKey();
  if (!publicKey) {
    throw new HttpError(503, 'Push notification belum dikonfigurasi di server');
  }
  return { publicKey };
}

/**
 * Simpan/update subscription push milik siswa.
 * Cek package web-push sama persis: hanya `if (!webpush)`, bukan cek VAPID.
 */
async function subscribe({ nis, subscription }) {
  if (!isWebPushPackageLoaded()) {
    throw new HttpError(503, 'Push notification belum tersedia di server (jalankan npm install)');
  }
  if (!nis || !subscription?.endpoint || !subscription?.keys?.p256dh || !subscription?.keys?.auth) {
    throw new HttpError(400, 'Data subscription tidak lengkap');
  }

  const siswaRows = await siswaModel.findIdOnlyByNis(nis);
  if (siswaRows.length === 0) {
    throw new HttpError(404, 'Siswa tidak ditemukan');
  }
  const siswaId = siswaRows[0].id;

  await notifikasiModel.upsertPushSubscription({
    siswaId,
    endpoint: subscription.endpoint,
    p256dh: subscription.keys.p256dh,
    auth: subscription.keys.auth,
  });

  return { message: 'Berlangganan push notification berhasil' };
}

/** Hapus subscription by endpoint. */
async function unsubscribe({ endpoint }) {
  if (!endpoint) {
    throw new HttpError(400, 'Endpoint wajib diisi');
  }
  await notifikasiModel.deletePushByEndpoint(endpoint);
  return { message: 'Berhenti berlangganan push notification' };
}

/** Riwayat notifikasi + unreadCount by NIS. */
async function listByNis(nis, limitQuery) {
  const limit = Math.min(parseInt(limitQuery, 10) || 30, 100);

  const siswaRows = await siswaModel.findIdOnlyByNis(nis);
  if (siswaRows.length === 0) {
    throw new HttpError(404, 'Siswa tidak ditemukan');
  }
  const siswaId = siswaRows[0].id;

  const rows = await notifikasiModel.listBySiswaId(siswaId, limit);
  const unreadCount = await notifikasiModel.countUnread(siswaId);

  return {
    notifikasi: rows.map((r) => ({ ...r, isRead: !!r.isRead })),
    unreadCount,
  };
}

/** Tandai satu notifikasi sudah dibaca. */
async function markRead(id) {
  const result = await notifikasiModel.markReadById(id);
  if (result.affectedRows === 0) {
    throw new HttpError(404, 'Notifikasi tidak ditemukan');
  }
}

/** Tandai semua notifikasi siswa (by NIS) sudah dibaca. */
async function markAllRead(nis) {
  const siswaRows = await siswaModel.findIdOnlyByNis(nis);
  if (siswaRows.length === 0) {
    throw new HttpError(404, 'Siswa tidak ditemukan');
  }
  await notifikasiModel.markAllReadBySiswaId(siswaRows[0].id);
}

/** Riwayat notifikasi Guru BK by username. */
async function listByGuruUsername(username, limitQuery) {
  if (!username) throw new HttpError(400, 'Username guru wajib diisi');
  const limit = Math.min(parseInt(limitQuery, 10) || 30, 100);
  try {
    const rows = await notifikasiModel.listByGuruUsername(username, limit);
    const unreadCount = await notifikasiModel.countUnreadGuru(username);
    return {
      notifikasi: rows.map((r) => ({ ...r, isRead: !!r.isRead })),
      unreadCount: Number(unreadCount) || 0,
    };
  } catch (err) {
    console.error('❌ listByGuruUsername error:', err.message);
    // Jangan biarkan 500 mentah — coba buat tabel lalu ulang sekali
    try {
      await notifikasiModel.ensureNotifikasiGuruTable();
      const rows = await notifikasiModel.listByGuruUsername(username, limit);
      const unreadCount = await notifikasiModel.countUnreadGuru(username);
      return {
        notifikasi: rows.map((r) => ({ ...r, isRead: !!r.isRead })),
        unreadCount: Number(unreadCount) || 0,
      };
    } catch (err2) {
      console.error('❌ listByGuruUsername retry gagal:', err2.message);
      throw new HttpError(500, `Gagal memuat notifikasi guru: ${err2.message}`);
    }
  }
}

async function markReadGuru(id) {
  const result = await notifikasiModel.markReadGuruById(id);
  if (result.affectedRows === 0) {
    throw new HttpError(404, 'Notifikasi tidak ditemukan');
  }
}

async function markAllReadGuru(username) {
  if (!username) throw new HttpError(400, 'Username guru wajib diisi');
  await notifikasiModel.markAllReadByGuruUsername(username);
}

module.exports = {
  initTables,
  getVapidKey,
  subscribe,
  unsubscribe,
  listByNis,
  markRead,
  markAllRead,
  listByGuruUsername,
  markReadGuru,
  markAllReadGuru,
};
