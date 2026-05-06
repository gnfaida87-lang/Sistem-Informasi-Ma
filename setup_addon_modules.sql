-- ==========================================
-- ADDON: AKADEMIK & KEUANGAN MODULES
-- ==========================================

-- 1. Tabel Kelas
CREATE TABLE IF NOT EXISTS public.kelas (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nama VARCHAR(50) NOT NULL UNIQUE,
    wali_kelas_id UUID REFERENCES public.guru(id),
    kapasitas INT DEFAULT 35,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Tabel Mata Pelajaran
CREATE TABLE IF NOT EXISTS public.mapel (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    kode VARCHAR(20) UNIQUE,
    kkm INT DEFAULT 75,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Tabel Absensi (Harian / Per Mapel)
CREATE TABLE IF NOT EXISTS public.absensi (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    siswa_id UUID REFERENCES public.siswa(id) ON DELETE CASCADE,
    tanggal DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) CHECK (status IN ('hadir', 'sakit', 'izin', 'alfa')),
    keterangan TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Tabel Nilai
CREATE TABLE IF NOT EXISTS public.nilai (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    siswa_id UUID REFERENCES public.siswa(id) ON DELETE CASCADE,
    mapel_id UUID REFERENCES public.mapel(id) ON DELETE CASCADE,
    jenis VARCHAR(50), -- Tugas, PTS, PAS
    skor FLOAT CHECK (skor >= 0 AND skor <= 100),
    semester INT CHECK (semester IN (1, 2)),
    tahun_ajaran VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Tabel Keuangan: Jenis Pembayaran
CREATE TABLE IF NOT EXISTS public.jenis_pembayaran (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    nominal DECIMAL(12, 2) NOT NULL,
    periode VARCHAR(20) CHECK (periode IN ('bulanan', 'sekali')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Tabel Keuangan: Pembayaran
CREATE TABLE IF NOT EXISTS public.pembayaran (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    siswa_id UUID REFERENCES public.siswa(id) ON DELETE CASCADE,
    jenis_id UUID REFERENCES public.jenis_pembayaran(id),
    jumlah DECIMAL(12, 2) NOT NULL,
    tanggal_bayar TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metode VARCHAR(50), -- Tunai, Transfer
    status VARCHAR(20) DEFAULT 'lunas',
    admin_id UUID REFERENCES public.users(id)
);
