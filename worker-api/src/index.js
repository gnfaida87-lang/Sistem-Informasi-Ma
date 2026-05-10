// ── UTILITY: SHA-256 HASHING ──────────────────────────────────
async function sha256(message) {
  const msgUint8 = new TextEncoder().encode(message);
  const hashBuffer = await crypto.subtle.digest("SHA-256", msgUint8);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
}

// ── UTILITY: CORS RESPONSE ────────────────────────────────────
function corsResponse(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, X-API-Key, Authorization",
      "Access-Control-Max-Age": "86400",
    },
  });
}

// ── HANDLER LOGIN ─────────────────────────────────────────────
async function handleLogin(request, env) {
  try {
    const body = await request.json();
    const { identifier, password } = body;

    if (!identifier || !password) {
      return corsResponse({ success: false, message: "Username dan password wajib diisi" }, 400);
    }

    // Cari user berdasarkan username atau email
    const userResult = await env.DB.prepare(`
      SELECT u.id, u.username, u.email, u.password_hash, u.is_active
      FROM users u
      WHERE (u.username = ? OR u.email = ?)
      LIMIT 1
    `).bind(identifier, identifier).all();

    if (!userResult.results || userResult.results.length === 0) {
      return corsResponse({ success: false, message: "Username atau password salah" }, 401);
    }

    const user = userResult.results[0];

    if (user.is_active === 0) {
      return corsResponse({ success: false, message: "Akun nonaktif, hubungi administrator" }, 403);
    }

    // Verifikasi password SHA-256
    const inputHash = await sha256(password);
    if (user.password_hash !== inputHash) {
      return corsResponse({ success: false, message: "Username atau password salah" }, 401);
    }

    // Ambil role user
    const rolesResult = await env.DB.prepare(`
      SELECT r.code, r.nama, ur.is_primary
      FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = ?
      ORDER BY ur.is_primary DESC
    `).bind(user.id).all();

    const primaryRole = rolesResult.results?.find(r => r.is_primary === 1)
      || rolesResult.results?.[0];

    // Cek apakah guru adalah wali kelas
    let isWaliKelas = false;
    if (primaryRole?.code === 'guru' || primaryRole?.code === 'GM' || primaryRole?.code === 'SA') {
      const teacherResult = await env.DB.prepare(
        "SELECT is_wali_kelas FROM teachers WHERE user_id = ? LIMIT 1"
      ).bind(user.id).all();
      isWaliKelas = teacherResult.results?.[0]?.is_wali_kelas === 1;
    }

    // Response sesuai struktur AppUser.fromJson di Flutter
    return corsResponse({
      success: true,
      user: {
        id:            user.id,
        username:      user.username,
        email:         user.email,
        full_name:     user.username,   // fallback ke username jika kolom full_name belum ada
        is_active:     user.is_active === 1,
        role_code:     primaryRole?.code  ?? null,
        role_name:     primaryRole?.nama  ?? null,
        is_wali_kelas: isWaliKelas,
      },
    });

  } catch (err) {
    console.error("Login error:", err);
    return corsResponse({ success: false, message: "Server error: " + err.message }, 500);
  }
}

// ── HANDLER QUERY ─────────────────────────────────────────────
async function handleQuery(request, env) {
  // Validasi API Key
  const apiKey = request.headers.get("X-API-Key");
  if (env.API_KEY && apiKey !== env.API_KEY) {
    return corsResponse({ success: false, message: "Unauthorized: API Key tidak valid" }, 401);
  }

  try {
    const body = await request.json();
    const { sql, params } = body;

    if (!sql) {
      return corsResponse({ success: false, message: "Field sql wajib ada" }, 400);
    }

    // Keamanan: blokir perintah berbahaya
    const sqlUpper = sql.trim().toUpperCase();
    const blocked = ["DROP TABLE", "DROP DATABASE", "TRUNCATE", "ATTACH DATABASE", "PRAGMA"];
    for (const b of blocked) {
      if (sqlUpper.includes(b)) {
        return corsResponse({ success: false, message: "Perintah SQL tidak diizinkan" }, 403);
      }
    }

    const result = await env.DB.prepare(sql).bind(...(params || [])).all();
    return corsResponse({ results: result.results || [], success: true });

  } catch (err) {
    console.error("Query error:", err);
    return corsResponse({ success: false, message: "Query error: " + err.message }, 500);
  }
}

// ── MAIN FETCH HANDLER ────────────────────────────────────────
export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // Handle CORS preflight
    if (request.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type, X-API-Key, Authorization",
          "Access-Control-Max-Age": "86400",
        },
      });
    }

    if (url.pathname === "/login")  return await handleLogin(request, env);
    if (url.pathname === "/query")  return await handleQuery(request, env);
    if (url.pathname === "/health") return corsResponse({ status: "ok", db: !!env.DB });

    return corsResponse({ success: false, message: "Not Found" }, 404);
  },
};
