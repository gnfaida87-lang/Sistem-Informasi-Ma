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
    const { identifier, password, deviceId, deviceName } = body;

    if (!identifier || !password) {
      return corsResponse({ success: false, message: "Username dan password wajib diisi" }, 400);
    }

    // 1. Ambil data user
    const userResult = await env.DB.prepare(`
      SELECT u.id, u.username, u.full_name, u.nis_nip, u.email, u.password_hash, u.is_active, u.profile_url
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

    // 2. Verifikasi Password
    const inputHash = await sha256(password);
    if (user.password_hash !== inputHash) {
      return corsResponse({ success: false, message: "Username atau password salah" }, 401);
    }

    // 3. VALIDASI DEVICE LIMIT (Maksimal 2 Perangkat)
    if (deviceId) {
      // Pastikan tabel sesi ada
      await env.DB.prepare(`
        CREATE TABLE IF NOT EXISTS user_sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT,
          device_id TEXT,
          device_name TEXT,
          last_active DATETIME DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(user_id, device_id)
        )
      `).run();

      // Cek apakah perangkat ini sudah terdaftar
      const existingSession = await env.DB.prepare(
        "SELECT id FROM user_sessions WHERE user_id = ? AND device_id = ?"
      ).bind(user.id, deviceId).all();

      if (!existingSession.results || existingSession.results.length === 0) {
        // Perangkat baru, cek jumlah sesi aktif
        const sessionCount = await env.DB.prepare(
          "SELECT COUNT(*) as count FROM user_sessions WHERE user_id = ?"
        ).bind(user.id).all();

        const count = sessionCount.results[0].count;
        if (count >= 2) {
          return corsResponse({ 
            success: false, 
            message: "Batas maksimal 2 perangkat tercapai. Silakan logout dari perangkat lain." 
          }, 403);
        }

        // Daftarkan perangkat baru
        await env.DB.prepare(
          "INSERT INTO user_sessions (user_id, device_id, device_name) VALUES (?, ?, ?)"
        ).bind(user.id, deviceId, deviceName || "Unknown Device").run();
      } else {
        // Perangkat lama, update waktu aktif
        await env.DB.prepare(
          "UPDATE user_sessions SET last_active = CURRENT_TIMESTAMP WHERE user_id = ? AND device_id = ?"
        ).bind(user.id, deviceId).run();
      }
    }

    // 4. Ambil Roles
    const rolesResult = await env.DB.prepare(`
      SELECT r.code, r.nama, ur.is_primary
      FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = ?
      ORDER BY ur.is_primary DESC
    `).bind(user.id).all();

    const primaryRole = rolesResult.results?.find(r => r.is_primary === 1)
      || rolesResult.results?.[0];

    let isWaliKelas = false;
    if (primaryRole?.code === 'guru' || primaryRole?.code === 'GM' || primaryRole?.code === 'SA') {
      const teacherResult = await env.DB.prepare(
        "SELECT is_wali_kelas FROM teachers WHERE user_id = ? LIMIT 1"
      ).bind(user.id).all();
      isWaliKelas = teacherResult.results?.[0]?.is_wali_kelas === 1;
    }

    return corsResponse({
      success: true,
      user: {
        id:            user.id,
        username:      user.username,
        full_name:     user.full_name || user.username,
        nis_nip:       user.nis_nip,
        email:         user.email,
        is_active:     user.is_active === 1,
        role_code:     primaryRole?.code  ?? null,
        role_name:     primaryRole?.nama  ?? null,
        is_wali_kelas: isWaliKelas,
        profile_url:   user.profile_url,
      },
    });

  } catch (err) {
    console.error("Login error:", err);
    return corsResponse({ success: false, message: "Server error: " + err.message }, 500);
  }
}

// ── HANDLER QUERY ─────────────────────────────────────────────
async function handleQuery(request, env) {
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

// ── HANDLER BACKUP ────────────────────────────────────────────
async function handleBackup(request, env) {
  const url = new URL(request.url);
  const apiKey = request.headers.get("X-API-Key") || url.searchParams.get("api_key");
  
  if (env.API_KEY && apiKey !== env.API_KEY) {
    return corsResponse({ success: false, message: "Unauthorized" }, 401);
  }

  try {
    const dump = await env.DB.dump();
    return new Response(dump, {
      status: 200,
      headers: {
        "Content-Type": "application/x-sqlite3",
        "Content-Disposition": `attachment; filename="backup_${Date.now()}.sqlite"`,
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, X-API-Key",
      },
    });
  } catch (err) {
    return corsResponse({ success: false, message: "Backup error: " + err.message }, 500);
  }
}

// ── HANDLER UPLOAD (R2 STORAGE) ───────────────────────────────
async function handleUpload(request, env) {
  const apiKey = request.headers.get("X-API-Key");
  if (env.API_KEY && apiKey !== env.API_KEY) {
    return corsResponse({ success: false, message: "Unauthorized" }, 401);
  }

  try {
    const formData = await request.formData();
    const file = formData.get("file");
    
    if (!file) {
      return corsResponse({ success: false, message: "File tidak ditemukan dalam request" }, 400);
    }

    // Nama file unik dengan timestamp
    const fileName = `${Date.now()}_${file.name.replace(/\s+/g, '_')}`;
    
    // Simpan ke R2 Bucket (Binding: STORAGE)
    await env.STORAGE.put(fileName, await file.arrayBuffer(), {
      httpMetadata: { contentType: file.type },
    });

    return corsResponse({
      success: true,
      fileKey: fileName,
      fileName: file.name,
      // URL akses melalui proxy worker
      fileUrl: `${new URL(request.url).origin}/file/${fileName}`
    });

  } catch (err) {
    console.error("Upload error:", err);
    return corsResponse({ success: false, message: "Upload error: " + err.message }, 500);
  }
}

// ── HANDLER GET FILE (R2 PROXY) ───────────────────────────────
async function handleGetFile(request, env) {
  const url = new URL(request.url);
  const key = url.pathname.split("/file/")[1];
  
  if (!key) return corsResponse({ success: false, message: "Key missing" }, 400);
  
  const object = await env.STORAGE.get(key);
  
  if (object === null) {
    return corsResponse({ success: false, message: "File tidak ditemukan" }, 404);
  }

  const headers = new Headers();
  object.writeHttpMetadata(headers);
  headers.set("Access-Control-Allow-Origin", "*");
  headers.set("etag", object.httpEtag);
  headers.set("Cache-Control", "public, max-age=31536000");

  return new Response(object.body, { headers });
}

// ── MAIN FETCH HANDLER ────────────────────────────────────────
export default {
  async fetch(request, env) {
    const url = new URL(request.url);

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
    if (url.pathname === "/upload") return await handleUpload(request, env);
    if (url.pathname.startsWith("/file/")) return await handleGetFile(request, env);
    if (url.pathname === "/backup") return await handleBackup(request, env);
    if (url.pathname === "/health") return corsResponse({ status: "ok", db: !!env.DB, storage: !!env.STORAGE });

    return corsResponse({ success: false, message: "Not Found" }, 404);
  },
};
