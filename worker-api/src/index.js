// Cloudflare Worker — API Bridge untuk Sistem Informasi Madrasah
// Menghubungkan Flutter App ↔ Cloudflare D1 Database

export default {
  async fetch(request, env) {
    // Handle CORS untuk Flutter Web
    if (request.method === "OPTIONS") {
      return corsResponse(null, 204);
    }

    const url = new URL(request.url);
    const path = url.pathname;

    try {
      // ── ROUTING ──────────────────────────────────────────
      if (path === "/login" && request.method === "POST") {
        return await handleLogin(request, env);
      }

      if (path === "/query" && request.method === "POST") {
        return await handleQuery(request, env);
      }

      if (path === "/health" && request.method === "GET") {
        return corsResponse({ status: "ok", message: "Worker aktif" });
      }

      return corsResponse({ error: "Endpoint tidak ditemukan" }, 404);

    } catch (err) {
      return corsResponse({ error: "Server error: " + err.message }, 500);
    }
  }
};

// ── HANDLER LOGIN ─────────────────────────────────────────────
async function handleLogin(request, env) {
  const body = await request.json();
  const { identifier, password } = body;

  if (!identifier || !password) {
    return corsResponse({ message: "Username dan password wajib diisi" }, 400);
  }

  // Cari user berdasarkan username atau email
  const userResult = await env.DB.prepare(`
    SELECT u.id, u.username, u.email, u.password_hash, u.is_active
    FROM users u
    WHERE (u.username = ? OR u.email = ?)
    LIMIT 1
  `).bind(identifier, identifier).all();

  if (!userResult.results || userResult.results.length === 0) {
    return corsResponse({ message: "Username atau password salah" }, 401);
  }

  const user = userResult.results[0];

  // Cek apakah user aktif
  if (!user.is_active) {
    return corsResponse({ message: "Akun tidak aktif" }, 403);
  }

  // Verifikasi password (plain text untuk saat ini, nanti bisa upgrade ke hash)
  if (user.password_hash !== password) {
    return corsResponse({ message: "Username atau password salah" }, 401);
  }

  // Ambil role user
  const roleResult = await env.DB.prepare(`
    SELECT r.code, r.nama, ur.is_primary
    FROM user_roles ur
    JOIN roles r ON ur.role_id = r.id
    WHERE ur.user_id = ?
    ORDER BY ur.is_primary DESC
  `).bind(user.id).all();

  const roles = roleResult.results || [];
  const primaryRole = roles.find(r => r.is_primary === 1) || roles[0];

  // Ambil data tambahan berdasarkan role
  let extraData = {};

  if (primaryRole) {
    if (['GM', 'GB', 'WK'].includes(primaryRole.code)) {
      // Data guru
      const teacherResult = await env.DB.prepare(`
        SELECT id, nip, name, is_wali_kelas FROM teachers WHERE user_id = ? LIMIT 1
      `).bind(user.id).all();
      if (teacherResult.results.length > 0) {
        extraData.teacher = teacherResult.results[0];
      }
    }

    if (primaryRole.code === 'ST') {
      // Data siswa
      const studentResult = await env.DB.prepare(`
        SELECT id, nis, name, class_id FROM students WHERE user_id = ? LIMIT 1
      `).bind(user.id).all();
      if (studentResult.results.length > 0) {
        extraData.student = studentResult.results[0];
      }
    }
  }

  return corsResponse({
    success: true,
    user: {
      id: user.id,
      username: user.username,
      email: user.email,
    },
    role: primaryRole ? primaryRole.code : null,
    roles: roles,
    ...extraData
  });
}

// ── HANDLER QUERY UMUM ────────────────────────────────────────
async function handleQuery(request, env) {
  const body = await request.json();
  const { sql, params } = body;

  if (!sql) {
    return corsResponse({ error: "SQL tidak boleh kosong" }, 400);
  }

  // Keamanan: blokir perintah berbahaya
  const sqlUpper = sql.trim().toUpperCase();
  const blockedCommands = ["DROP TABLE", "DROP DATABASE", "TRUNCATE", "ALTER TABLE"];
  for (const cmd of blockedCommands) {
    if (sqlUpper.includes(cmd)) {
      return corsResponse({ error: "Perintah SQL tidak diizinkan" }, 403);
    }
  }

  const stmt = params && params.length > 0
    ? env.DB.prepare(sql).bind(...params)
    : env.DB.prepare(sql);

  const result = await stmt.all();

  return corsResponse({
    results: result.results || [],
    success: result.success,
    meta: result.meta
  });
}

// ── HELPER: Response dengan CORS Headers ──────────────────────
function corsResponse(data, status = 200) {
  const headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, X-API-Key, Authorization",
  };

  return new Response(
    data !== null ? JSON.stringify(data) : null,
    { status, headers }
  );
}
