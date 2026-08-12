// utils/sanitize.js
// Filter privasi teks chat / AI + batasi role dari client.

function sanitizeText(text) {
    if (!text || typeof text !== 'string') return text;
    return text
        .replace(/\b(nama saya|saya bernama|aku bernama)\s+[a-zA-Z\s]+/gi, '[IDENTITAS DIHAPUS]')
        .replace(/\b\d{8,}\b/g, '[NOMOR DIHAPUS]')
        .replace(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/gi, '[EMAIL DIHAPUS]')
        .replace(/\b(alamat saya|tinggal di)\s+.+/gi, '[ALAMAT DIHAPUS]');
}

/**
 * Hanya pertahankan pesan role=user dari client.
 * Role system/assistant dari client diabaikan agar tidak bypass system prompt.
 */
function sanitizeMessages(messages) {
    if (!Array.isArray(messages)) return [];
    return messages
        .filter((msg) => msg && (msg.role === 'user' || msg.role === 'assistant'))
        // assistant dari client juga berisiko — batasi hanya user untuk input AI
        .filter((msg) => msg.role === 'user')
        .map((msg) => ({
            role: 'user',
            content: sanitizeText(String(msg.content || '')),
        }));
}

module.exports = { sanitizeText, sanitizeMessages };
