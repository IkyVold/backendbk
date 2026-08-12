// utils/chatSession.js
/** Format session room: konseling_<id> */
function sessionIdFromKonselingId(konselingId) {
  const id = Number(konselingId);
  if (!id || Number.isNaN(id)) return null;
  return `konseling_${id}`;
}

function parseKonselingIdFromSession(sessionId) {
  const m = String(sessionId || '').match(/^konseling_(\d+)$/);
  return m ? Number(m[1]) : null;
}

module.exports = {
  sessionIdFromKonselingId,
  parseKonselingIdFromSession,
};
