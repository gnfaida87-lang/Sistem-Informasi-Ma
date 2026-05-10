// ── UTILITY: SHA-256 HASHING ──────────────────────────────────
async function sha256(message) {
  const msgUint8 = new TextEncoder().encode(message);
  const hashBuffer = await crypto.subtle.digest("SHA-256", msgUint8);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
}

// ── UTILITY: CORS RESPONSE ───────────────────────────────────
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
      return corsResponse({ message: "Username dan password wajib diisi" }, 400);
    }

    const userResult = await env.DB.prepare(`
      SELECT u.id, u.username, u.email, u.password_hash, u.is_active
      FROM users u
      WHERE (u.username = ? OR u.email = ?)
      LIMIT 1
    `).bind(identifier, identifier).all();

    if (!userResult.results || userResult.results.length === 0) {
      return corsResponse({ message: `Username '${identifier}' tidak ditemukan di database` }, 401);
    }

    const user = userResult.results[0];
    if (user.is_active === 0) return corsResponse({ message: "Akun nonaktif" }, 403);

    // Verifikasi SHA-256
    const inputHash = await sha256(password);
    if (user.password_hash !== inputHash) {
      return corsResponse({ 
        message: "Password salah", 
        debug: {
          input_hash: inputHash,
          stored_hash: user.password_hash
        } 
      }, 401);
    }

    const rolesResult = await env.DB.prepare(`
      SELECT r.code, r.nama, ur.is_primary
      FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = ?
    `).bind(user.id).all();

    return corsResponse({
      success: true,
      user: { id: user.id, username: user.username, email: user.email },
      role: rolesResult.results.find(r => r.is_primary === 1)?.code || rolesResult.results[0]?.code,
      roles: rolesResult.results
    });
  } catch (err) {
    return corsResponse({ message: "Server error", error: err.message }, 500);
  }
}

// ── HANDLER QUERY ─────────────────────────────────────────────
async function handleQuery(request, env) {
  // Cek API Key untuk keamanan ekstra sesuai analisis Anda
  const apiKey = request.headers.get("X-API-Key");
  if (apiKey !== env.API_KEY && env.API_KEY) {
    return corsResponse({ message: "Unauthorized: Invalid API Key" }, 401);
  }

  try {
    const body = await request.json();
    const { sql, params } = body;
    const result = await env.DB.prepare(sql).bind(...(params || [])).all();
    return corsResponse({ results: result.results || [], success: true });
  } catch (err) {
    return corsResponse({ message: "Query error", error: err.message }, 500);
  }
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === "OPTIONS") {
      return new Response(null, {
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type, X-API-Key, Authorization",
          "Access-Control-Max-Age": "86400",
        }
      });
    }

    if (url.pathname === "/login") return await handleLogin(request, env);
    if (url.pathname === "/query") return await handleQuery(request, env);
    if (url.pathname === "/health") return corsResponse({ status: "ok" });

    return corsResponse({ message: "Not Found" }, 404);
  }
};
