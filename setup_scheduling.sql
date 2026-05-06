-- ==========================================
-- SCHEDULING MODULE
-- ==========================================

-- 1. Table: Jam Pelajaran (Time Slots)
CREATE TABLE IF NOT EXISTS public.jam_pelajaran (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    hari VARCHAR(20) NOT NULL, -- 'Senin', 'Selasa', etc.
    jam_ke INT, -- 1, 2, 3...
    waktu_mulai TIME NOT NULL,
    waktu_selesai TIME NOT NULL,
    is_istirahat BOOLEAN DEFAULT false,
    label VARCHAR(100), -- e.g. 'Istirahat I', 'Upacara'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Table: Jadwal Pelajaran (Teaching Schedule)
CREATE TABLE IF NOT EXISTS public.jadwal_pelajaran (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    semester_id UUID REFERENCES public.semester(id) ON DELETE CASCADE,
    kelas_id UUID REFERENCES public.kelas(id) ON DELETE CASCADE,
    jam_pelajaran_id UUID REFERENCES public.jam_pelajaran(id) ON DELETE CASCADE,
    guru_id UUID REFERENCES public.guru(id) ON DELETE CASCADE,
    mapel_id UUID REFERENCES public.mapel(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(semester_id, kelas_id, jam_pelajaran_id) -- One slot in one class can only have one teacher/subject
);

-- RLS POLICIES

-- Jam Pelajaran
ALTER TABLE public.jam_pelajaran ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public Read Jam Pelajaran" ON public.jam_pelajaran FOR SELECT USING (true);
CREATE POLICY "WK Manage Jam Pelajaran" ON public.jam_pelajaran FOR ALL USING (
    EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.code = 'WK')
);

-- Jadwal Pelajaran
ALTER TABLE public.jadwal_pelajaran ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public Read Jadwal Pelajaran" ON public.jadwal_pelajaran FOR SELECT USING (true);
CREATE POLICY "WK Manage Jadwal Pelajaran" ON public.jadwal_pelajaran FOR ALL USING (
    EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.code = 'WK')
);

-- SEED DATA: Default Time Slots for Senin
INSERT INTO public.jam_pelajaran (hari, jam_ke, waktu_mulai, waktu_selesai, is_istirahat, label) VALUES
('Senin', 0, '07:15:00', '08:00:00', true, 'Upacara Bendera'),
('Senin', 1, '08:00:00', '08:45:00', false, NULL),
('Senin', 2, '08:45:00', '09:30:00', false, NULL),
('Senin', NULL, '09:30:00', '09:45:00', true, 'Istirahat I'),
('Senin', 3, '09:45:00', '10:30:00', false, NULL),
('Senin', 4, '10:30:00', '11:15:00', false, NULL),
('Senin', 5, '11:15:00', '12:00:00', false, NULL),
('Senin', NULL, '12:00:00', '12:45:00', true, 'Istirahat II / ISHOMA')
ON CONFLICT DO NOTHING;
