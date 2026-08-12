# Backend Refactor — Stop Bullying (BK System)

Arsitektur berlapis (pure refactor, perilaku API tidak diubah):

```
routes/  →  controllers/  →  services/  →  models/  →  MySQL
                              ↑
                    utils/ + middleware/
socket/  →  services/chatService  →  models/chatModel
```

## Layer

| Layer | Tanggung jawab |
|-------|----------------|
| **routes/** | Definisi endpoint + middleware (multer, dsb.) |
| **controllers/** | req/res + `asyncHandler` |
| **services/** | Konfirmasi & logika bisnis |
| **models/** | Pure query SQL (satu-satunya yang pakai `pool`) |
| **socket/** | Handler Socket.IO (event name & payload sama) |
| **utils/** | `HttpError`, `sanitize` |
| **middleware/** | `asyncHandler`, `errorHandler` |

## Models

- `siswaModel.js` — tabel `siswa`
- `riwayatKelasModel.js` — tabel `riwayat_kelas`
- `informasiModel.js` — tabel `informasi_bk`
- `konselingModel.js` — tabel `konseling`
- `notifikasiModel.js` — tabel `notifikasi` + `push_subscriptions`
- `chatModel.js` — tabel `chat_messages`

## Menjalankan

```bash
npm install
cp .env.example .env
npm start
```

Semua endpoint, event Socket.IO, Web Push, dan response shape
**tidak diubah** — hanya pemisahan folder/layer.


## JWT Authentication

Hampir semua endpoint (kecuali login) wajib header:

```
Authorization: Bearer <token>
```

Token didapat dari response login (`token` field).

Role:
- `siswa` — data sendiri, ajukan konseling, chat AI, notifikasi
- `guru` — daftar siswa, konfirmasi, laporan, foto profil guru
- `kepsek` — monitoring semua konseling
- `admin` — CRUD akun guru/kepsek

Socket.IO: kirim `auth: { token }` saat connect.

Env: `JWT_SECRET`, `JWT_EXPIRES_IN` (default 12h).

```bash
npm install
```
