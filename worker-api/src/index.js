// ── UTILITY: CORS RESPONSE ───────────────────────────────────
function corsResponse(data, status = 200) {
  const headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, X-API-Key, Authorization, Accept, Origin",
    "Access-Control-Max-Age": "86400",
  };

  return new Response(JSON.stringify(data), {
    status,
    headers
  });
}

// ── HANDLER LOGIN ─────────────────────────────────────────────
async function handleLogin(request, env) {
  try {
    const body = await request.json();
    const { identifier, password } = body;

    console.log("Login attempt for:", identifier);

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
      console.log("User not found:", identifier);
      return corsResponse({ message: "Username atau password salah" }, 401);
    }

    const user = userResult.results[0];

    // Cek status aktif
    if (user.is_active === 0) {
      return corsResponse({ message: "Akun Anda dinonaktifkan" }, 403);
    }

    // Verifikasi password (plain text)
    if (user.password_hash !== password) {
      console.log("Wrong password for:", identifier);
      return corsResponse({ message: "Username atau password salah" }, 401);
    }

    // Ambil roles user
    const rolesResult = await env.DB.prepare(`
      SELECT r.code, r.nama, ur.is_primary
      FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = ?
    `).bind(user.id).all();

    console.log("Login success for:", identifier);

    return corsResponse({
      success: true,
      user: {
        id: user.id,
        username: user.username,
        email: user.email
      },
      role: rolesResult.results.find(r => r.is_primary === 1)?.code || rolesResult.results[0]?.code,
      roles: rolesResult.results
    });
  } catch (err) {
    console.error("Login error:", err);
    return corsResponse({ message: "Server error", error: err.message }, 500);
  }
}

// ── HANDLER QUERY ─────────────────────────────────────────────
async function handleQuery(request, env) {
  try {
    const body = await request.json();
    const { sql, params } = body;

    if (!sql) {
      return corsResponse({ message: "SQL query wajib diisi" }, 400);
    }

    // Eksekusi query
    const result = await env.DB.prepare(sql).bind(...(params || [])).all();

    // D1Service di Flutter mengharapkan objek dengan key "results"
    return corsResponse({
      results: result.results || [],
      success: true,
      meta: result.meta
    });
  } catch (err) {
    console.error("Query error:", err);
    return corsResponse({ 
      message: "Gagal menjalankan query", 
      error: err.message 
    }, 500);
  }
}

// ── MAIN FETCH HANDLER ────────────────────────────────────────
export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    // Handle Preflight Request (OPTIONS)
    if (request.method === "OPTIONS") {
      return new Response(null, {
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type, X-API-Key, Authorization, Accept, Origin",
          "Access-Control-Max-Age": "86400",
        }
      });
    }

    try {
      if (url.pathname === "/login" && request.method === "POST") {
        return await handleLogin(request, env);
      }

      if (url.pathname === "/query" && request.method === "POST") {
        return await handleQuery(request, env);
      }

      if (url.pathname === "/health") {
        return corsResponse({ status: "ok", message: "Worker aktif" });
      }

      return corsResponse({ message: "Endpoint tidak ditemukan" }, 404);
    } catch (e) {
      return corsResponse({ message: "Internal Server Error", error: e.message }, 500);
    }
  },
};
