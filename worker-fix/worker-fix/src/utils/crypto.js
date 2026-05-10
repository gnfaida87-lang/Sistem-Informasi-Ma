/**
 * crypto.js — Verifikasi password menggunakan Web Crypto API (native di Workers)
 * TIDAK butuh bcryptjs atau library eksternal apapun.
 */

/**
 * Ubah string plain text menjadi SHA-256 hex string
 */
async function sha256(text) {
  const enc = new TextEncoder();
  const buf = await crypto.subtle.digest('SHA-256', enc.encode(text));
  return [...new Uint8Array(buf)]
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
}

/**
 * Verifikasi password: bandingkan plain text dengan hash SHA-256 di database
 */
export async function verifyPassword(plainPassword, storedHash) {
  try {
    const hashed = await sha256(plainPassword);
    return hashed === storedHash;
  } catch (err) {
    console.error('verifyPassword error:', err);
    return false;
  }
}

/**
 * Hash password baru (digunakan saat create/reset user)
 */
export async function hashPassword(plainPassword) {
  return await sha256(plainPassword);
}
