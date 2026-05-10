-- ============================================================
-- UPDATE PASSWORD SUPERADMIN KE SHA-256
-- Jalankan di: Cloudflare Dashboard → D1 → si-madrasah → Console
-- ============================================================

-- SHA-256 dari password "Admin@123"
UPDATE users
SET password = 'e86f78a8a3caf0b60d8e74e5942aa6d86dc150cd3c03338aef25b7d2d7e3acc7'
WHERE username = 'superadmin';

-- Verifikasi: pastikan 1 row berhasil diupdate
SELECT id, username, full_name,
       CASE WHEN password = 'e86f78a8a3caf0b60d8e74e5942aa6d86dc150cd3c03338aef25b7d2d7e3acc7'
            THEN 'OK - hash sudah benar'
            ELSE 'ERROR - hash tidak cocok'
       END AS status
FROM users
WHERE username = 'superadmin';
