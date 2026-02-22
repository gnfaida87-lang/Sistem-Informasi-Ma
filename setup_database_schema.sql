-- ==============================================================
-- DOKUMEN: SINKRONISASI DATA & ROLE - DATABASE SCHEMA
-- STATUS: FINAL PANDUAN HARD ARCHITECTURE
-- ==============================================================
-- SQL INI WAJIB DIJALANKAN DI SUPABASE SQL EDITOR
-- ==============================================================

-- 1. EXTENSION
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- 2. ENTITAS UTAMA (AUTH & ROLE MANAGEMENT)
-- ==========================================

-- Tabel public.users (Sinkronisasi otomatis dengan auth.users)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    username VARCHAR(100) UNIQUE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE
);

-- Tabel Master Role (Tidak Boleh Diubah AI)
CREATE TABLE IF NOT EXISTS public.roles (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT
);

-- Menyisipkan (Seed) Data Role Sesuai Spesifikasi Final
INSERT INTO public.roles (code, name, description) VALUES 
('SA', 'Superadmin', 'Sistem, keamanan, dan log'),
('KM', 'Kepala Madrasah', 'Laporan tingkat tinggi'),
('WK', 'Wakil Kurikulum', 'Jadwal dan Rapot Akademik'),
('OP', 'Operator Data', 'Master Data Siswa, Guru, Kelas'),
('AK', 'Admin Keuangan', 'Pembayaran dan Keuangan'),
('GM', 'Guru Mata Pelajaran', 'Input Nilai dan Absensi'),
('GB', 'Guru Bimbel', 'Tutor Eksternal Bimbel'),
('OT', 'Orang Tua Siswa', 'Bisa melihat data akademik & keuangan anak')
ON CONFLICT (code) DO NOTHING;

-- Tabel Relasi User ke Role (Aturan: Satu User Satu Role Primary)
CREATE TABLE IF NOT EXISTS public.user_roles (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    role_id INT REFERENCES public.roles(id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, role_id)
);

-- ==========================================
-- 3. TRIGGER: SINKRONISASI AUTH.USERS KE PUBLIC.USERS
-- ==========================================
-- Mencegah inkonsistensi data ketika ada user yang daftar di auth
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, username)
  VALUES (new.id, new.email, split_part(new.email, '@', 1));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Memicu fungsi setiap kali ada User baru di Auth Supabase
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ==========================================
-- 4. ENTITAS PROFIL BERDASARKAN ROLE
-- ==========================================

-- Tabel Guru / Staf Pengajar
CREATE TABLE IF NOT EXISTS public.guru (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    nip VARCHAR(50) UNIQUE,
    nama VARCHAR(255) NOT NULL,
    is_wali_kelas BOOLEAN DEFAULT false, -- FLAG WALI KELAS
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabel Siswa (Master Data)
CREATE TABLE IF NOT EXISTS public.siswa (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nis VARCHAR(50) UNIQUE NOT NULL,
    nama VARCHAR(255) NOT NULL,
    kelas_id UUID, -- Foreign Key ke Tabel Kelas (nanti dibuat OP)
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabel Orang Tua
CREATE TABLE IF NOT EXISTS public.orang_tua (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    nama VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Relasi Orang Tua dan Siswa
CREATE TABLE IF NOT EXISTS public.orang_tua_siswa (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    orang_tua_id UUID REFERENCES public.orang_tua(id) ON DELETE CASCADE,
    siswa_id UUID REFERENCES public.siswa(id) ON DELETE CASCADE,
    UNIQUE(orang_tua_id, siswa_id)
);

-- ==========================================
-- 5. PENGUNCIAN KEAMANAN (RLS: ROW LEVEL SECURITY)
-- ==========================================
-- Mengaktifkan RLS pada seluruh tabel penting
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.guru ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.siswa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orang_tua ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orang_tua_siswa ENABLE ROW LEVEL SECURITY;

-- Kebijakan Dasar (Basic Policies)
-- User hanya bisa melihat datanya sendiri
CREATE POLICY "Users can view own data" ON public.users FOR SELECT USING (auth.uid() = id);
-- User bisa melihat rolenya sendiri
CREATE POLICY "Users can view own role" ON public.user_roles FOR SELECT USING (auth.uid() = user_id);
-- Semua User yang login bebas membaca tabel master Role 
CREATE POLICY "All users can view roles" ON public.roles FOR SELECT USING (true);

-- (Catatan: Policy Lanjutan untuk OP, WK, GM, dll akan di-setup dalam modul master data terpisah)
