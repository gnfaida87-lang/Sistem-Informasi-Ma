-- Tambah kolom untuk foto profil siswa
ALTER TABLE students ADD COLUMN foto_url TEXT;

-- Tambah kolom untuk dokumen guru
ALTER TABLE teachers ADD COLUMN dokumen_url TEXT;
