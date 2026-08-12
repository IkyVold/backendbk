// middleware/auth.js
// JWT authentication (HttpOnly cookie + optional Bearer) & role authorization.
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const HttpError = require('../utils/HttpError');

const JWT_SECRET = process.env.JWT_SECRET || 'bk-system-dev-secret-ganti-di-production';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '12h';
const COOKIE_MAX_MS = 12 * 60 * 60 * 1000;

const IS_PROD = process.env.NODE_ENV === 'production';

function cookieBaseOptions() {
  return {
    httpOnly: true,
    secure: IS_PROD, // production: HTTPS only
    sameSite: IS_PROD ? 'none' : 'lax', // cross-site prod butuh None+Secure
    path: '/',
    maxAge: COOKIE_MAX_MS,
  };
}

function signToken(payload) {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
}

function verifyToken(token) {
  return jwt.verify(token, JWT_SECRET);
}

function authCookieName(role) {
  return `auth_token_${role}`;
}

/** Set JWT HttpOnly cookie untuk role. */
function setAuthCookie(res, token, role) {
  // Hapus cookie role lain (opsi harus sama dengan saat set, tanpa maxAge)
  const clearOpts = {
    httpOnly: true,
    secure: IS_PROD,
    sameSite: IS_PROD ? 'none' : 'lax',
    path: '/',
  };
  ['siswa', 'guru', 'kepsek', 'admin'].forEach((r) => {
    if (r !== role) res.clearCookie(authCookieName(r), clearOpts);
  });

  res.cookie(authCookieName(role), token, cookieBaseOptions());
  res.cookie('auth_active_role', role, {
    httpOnly: false,
    secure: IS_PROD,
    sameSite: IS_PROD ? 'none' : 'lax',
    path: '/',
    maxAge: COOKIE_MAX_MS,
  });
}

function clearAuthCookie(res, role) {
  const opts = { ...cookieBaseOptions(), maxAge: 0 };
  if (role) {
    res.clearCookie(authCookieName(role), opts);
  } else {
    ['siswa', 'guru', 'kepsek', 'admin'].forEach((r) => {
      res.clearCookie(authCookieName(r), opts);
    });
  }
  res.clearCookie('auth_active_role', {
    httpOnly: false,
    secure: IS_PROD,
    sameSite: IS_PROD ? 'none' : 'lax',
    path: '/',
  });
}

/** CSRF double-submit cookie (bukan HttpOnly agar frontend bisa baca). */
function setCsrfCookie(res) {
  const token = crypto.randomBytes(32).toString('hex');
  res.cookie('csrf_token', token, {
    httpOnly: false,
    secure: IS_PROD,
    sameSite: IS_PROD ? 'none' : 'lax',
    path: '/',
    maxAge: COOKIE_MAX_MS,
  });
  return token;
}

function clearCsrfCookie(res) {
  res.clearCookie('csrf_token', {
    httpOnly: false,
    secure: IS_PROD,
    sameSite: IS_PROD ? 'none' : 'lax',
    path: '/',
  });
}

/**
 * Ambil JWT dari:
 * 1) Authorization: Bearer
 * 2) Cookie auth_token_<role> (role dari X-Auth-Role / cookie auth_active_role)
 * 3) Query token (Socket.IO fallback)
 */
function extractToken(req) {
  const header = req.headers.authorization || '';
  if (header.startsWith('Bearer ')) {
    return header.slice(7).trim();
  }

  if (req.cookies) {
    const roleHint = (
      req.headers['x-auth-role'] ||
      req.cookies.auth_active_role ||
      ''
    ).toString().trim().toLowerCase();

    if (roleHint) {
      const named = req.cookies[authCookieName(roleHint)];
      if (named) return named;
      // Cookie role spesifik belum ada (mis. beda port / cookie diblokir)
      // jangan return null dulu — biarkan fallback Bearer di bawah (sudah dicek di atas)
    } else {
      for (const r of ['guru', 'admin', 'siswa', 'kepsek']) {
        if (req.cookies[authCookieName(r)]) return req.cookies[authCookieName(r)];
      }
    }
  }

  if (req.query && req.query.token) {
    return String(req.query.token);
  }

  return null;
}

function authenticate(req, res, next) {
  const token = extractToken(req);
  if (!token) {
    return next(new HttpError(401, 'Autentikasi diperlukan. Silakan login terlebih dahulu.'));
  }
  try {
    req.user = verifyToken(token);
    next();
  } catch (err) {
    return next(new HttpError(401, 'Sesi tidak valid atau sudah kedaluwarsa. Silakan login ulang.'));
  }
}

function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user) {
      return next(new HttpError(401, 'Autentikasi diperlukan.'));
    }
    if (!roles.includes(req.user.role)) {
      return next(new HttpError(403, 'Anda tidak memiliki akses ke resource ini.'));
    }
    next();
  };
}

function requireSelfOrStaff(param = 'nis') {
  return (req, res, next) => {
    if (!req.user) {
      return next(new HttpError(401, 'Autentikasi diperlukan.'));
    }
    const staff = ['guru', 'admin', 'kepsek'];
    if (staff.includes(req.user.role)) return next();

    if (req.user.role === 'siswa') {
      const target =
        req.params[param] ||
        req.body?.[param] ||
        req.query?.[param];
      if (target != null && String(target) === String(req.user.nis)) {
        return next();
      }
      return next(new HttpError(403, 'Anda hanya dapat mengakses data milik sendiri.'));
    }

    return next(new HttpError(403, 'Akses ditolak.'));
  };
}

/**
 * CSRF: double-submit cookie.
 * Skip untuk GET/HEAD/OPTIONS dan path login publik.
 */
function csrfProtect(req, res, next) {
  const method = req.method.toUpperCase();
  if (['GET', 'HEAD', 'OPTIONS'].includes(method)) {
    return next();
  }

  // Login/register boleh tanpa CSRF (belum punya cookie)
  const path = (req.originalUrl || req.url || '').split('?')[0];
  const publicMutations = [
    '/api/login',
    '/api/login-guru',
    '/api/login-kepsek',
    '/api/login-admin',
    '/api/register',
    '/api/registrasi',
  ];
  if (publicMutations.some((p) => path === p || path.endsWith(p))) {
    return next();
  }

  const cookieToken = req.cookies && req.cookies.csrf_token;
  const headerToken = req.get('X-CSRF-Token') || req.get('x-csrf-token');
  if (!cookieToken || !headerToken || cookieToken !== headerToken) {
    return next(new HttpError(403, 'CSRF token tidak valid. Muat ulang halaman dan coba lagi.'));
  }
  return next();
}

/** Parse cookie header mentah (untuk Socket.IO handshake). */
function parseCookieHeader(cookieHeader) {
  const out = {};
  if (!cookieHeader) return out;
  String(cookieHeader)
    .split(';')
    .forEach((part) => {
      const idx = part.indexOf('=');
      if (idx === -1) return;
      const k = part.slice(0, idx).trim();
      const v = decodeURIComponent(part.slice(idx + 1).trim());
      out[k] = v;
    });
  return out;
}

function extractTokenFromSocket(socket) {
  const authToken = socket.handshake.auth?.token || socket.handshake.query?.token;
  if (authToken) return String(authToken);

  const cookies = parseCookieHeader(socket.handshake.headers?.cookie);
  // Prioritas role: handshake.auth.role (dari frontend) > cookie auth_active_role
  const roleHint =
    (socket.handshake.auth && socket.handshake.auth.role) ||
    socket.handshake.query?.role ||
    cookies.auth_active_role ||
    null;
  if (roleHint && cookies[authCookieName(String(roleHint))]) {
    return cookies[authCookieName(String(roleHint))];
  }
  // Jangan ambil token role lain secara sembarangan — hindari siswa kirim sebagai guru
  return null;
}

module.exports = {
  JWT_SECRET,
  signToken,
  verifyToken,
  authenticate,
  requireRole,
  requireSelfOrStaff,
  setAuthCookie,
  clearAuthCookie,
  setCsrfCookie,
  clearCsrfCookie,
  csrfProtect,
  extractToken,
  extractTokenFromSocket,
  authCookieName,
};
