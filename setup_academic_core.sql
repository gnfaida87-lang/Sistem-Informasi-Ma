-- ==========================================
-- ACADEMIC CORE MODULE
-- ==========================================

-- 1. Table: Jurusan (Departments)
CREATE TABLE IF NOT EXISTS public.jurusan (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    kode VARCHAR(20) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Table: Tahun Ajaran (Academic Years)
CREATE TABLE IF NOT EXISTS public.tahun_ajaran (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    tahun VARCHAR(20) UNIQUE NOT NULL, -- e.g. '2025/2026'
    is_active BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Table: Semester
CREATE TABLE IF NOT EXISTS public.semester (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    tahun_ajaran_id UUID REFERENCES public.tahun_ajaran(id) ON DELETE CASCADE,
    nama VARCHAR(20) NOT NULL, -- 'Ganjil' or 'Genap'
    is_active BOOLEAN DEFAULT false,
    kkm_default INT DEFAULT 75,
    is_validated BOOLEAN DEFAULT false, -- WK Validates this
    validated_by UUID REFERENCES public.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(tahun_ajaran_id, nama)
);

-- RLS POLICIES

-- Jurusan
ALTER TABLE public.jurusan ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public Read Jurusan" ON public.jurusan FOR SELECT USING (true);
CREATE POLICY "OP Manage Jurusan" ON public.jurusan FOR ALL USING (
    EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.code = 'OP')
);

-- Tahun Ajaran
ALTER TABLE public.tahun_ajaran ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public Read Tahun Ajaran" ON public.tahun_ajaran FOR SELECT USING (true);
CREATE POLICY "OP Manage Tahun Ajaran" ON public.tahun_ajaran FOR ALL USING (
    EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.code = 'OP')
);

-- Semester
ALTER TABLE public.semester ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public Read Semester" ON public.semester FOR SELECT USING (true);
CREATE POLICY "OP Manage Semester" ON public.semester FOR ALL USING (
    EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.code = 'OP')
);
CREATE POLICY "WK Validate Semester" ON public.semester FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.code = 'WK')
);

-- SEED DATA
INSERT INTO public.jurusan (kode, nama) VALUES 
('MIPA', 'Matematika dan Ilmu Pengetahuan Alam'),
('IPS', 'Ilmu Pengetahuan Sosial'),
('BAHASA', 'Ilmu Bahasa dan Budaya')
ON CONFLICT DO NOTHING;

INSERT INTO public.tahun_ajaran (tahun, is_active) VALUES 
('2025/2026', true),
('2024/2025', false)
ON CONFLICT DO NOTHING;

DO $$ 
DECLARE 
    ta25 UUID;
    ta24 UUID;
BEGIN
    SELECT id INTO ta25 FROM public.tahun_ajaran WHERE tahun = '2025/2026';
    SELECT id INTO ta24 FROM public.tahun_ajaran WHERE tahun = '2024/2025';

    IF ta25 IS NOT NULL THEN
        INSERT INTO public.semester (tahun_ajaran_id, nama, is_active, kkm_default, is_validated) 
        VALUES (ta25, 'Ganjil', true, 75, true) ON CONFLICT DO NOTHING;
    END IF;

    IF ta24 IS NOT NULL THEN
        INSERT INTO public.semester (tahun_ajaran_id, nama, is_active, kkm_default, is_validated) 
        VALUES (ta24, 'Genap', false, 75, true) ON CONFLICT DO NOTHING;
    END IF;
END $$;
