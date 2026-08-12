// Jalankan sekali: node scripts/generate-vapid-keys.js
// Salin hasilnya ke backend/.env (VAPID_PUBLIC_KEY, VAPID_PRIVATE_KEY)
// dan ke frontend/.env (VITE_VAPID_PUBLIC_KEY = VAPID_PUBLIC_KEY yang sama).
const webpush = require('web-push');

const keys = webpush.generateVAPIDKeys();

console.log('\n=== VAPID Keys ===');
console.log('VAPID_PUBLIC_KEY=' + keys.publicKey);
console.log('VAPID_PRIVATE_KEY=' + keys.privateKey);
console.log('\nTambahkan VAPID_PUBLIC_KEY & VAPID_PRIVATE_KEY di atas ke backend/.env');
console.log('Lalu tambahkan VITE_VAPID_PUBLIC_KEY=' + keys.publicKey + ' ke frontend/.env\n');
