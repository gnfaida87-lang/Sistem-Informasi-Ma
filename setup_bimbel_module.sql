-- ==============================================================
-- MODUL: BIMBEL & TUTOR EKSTERNAL
-- STATUS: INTEGRASI DATABASE RIIEL
-- ==============================================================

-- 1. Tabel Program Bimbel (Master Program)
CREATE TABLE IF NOT EXISTS public.program_bimbel (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    guru_id UUID REFERENCES public.guru(id) ON DELETE SET NULL, -- Tutor / Pengajar
    jadwal_info TEXT, -- Keterangan hari/jam
    status VARCHAR(20) DEFAULT 'active', -- active, inactive, completed
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Tabel Peserta Bimbel (Relasi Siswa ke Program)
CREATE TABLE IF NOT EXISTS public.peserta_bimbel (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    program_id UUID REFERENCES public.program_bimbel(id) ON DELETE CASCADE,
    siswa_id UUID REFERENCES public.siswa(id) ON DELETE CASCADE,
    tgl_daftar DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'active', -- active, dropout, graduated
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(program_id, siswa_id)
);

-- 3. Tabel Bimbel Sessions (Pertemuan / Sesi)
CREATE TABLE IF NOT EXISTS public.bimbel_sessions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    program_id UUID REFERENCES public.program_bimbel(id) ON DELETE CASCADE,
    teacher_id UUID REFERENCES public.guru(id) ON DELETE CASCADE,
    topic VARCHAR(255),
    session_date TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_minutes INT DEFAULT 90,
    room_info VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Tabel Bimbel Progress (Absensi & Nilai Sesi)
CREATE TABLE IF NOT EXISTS public.bimbel_progress (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    session_id UUID REFERENCES public.bimbel_sessions(id) ON DELETE CASCADE,
    student_id UUID REFERENCES public.siswa(id) ON DELETE CASCADE,
    is_present BOOLEAN DEFAULT true,
    score FLOAT DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(session_id, student_id)
);

-- ==========================================
-- KEAMANAN (RLS: ROW LEVEL SECURITY)
-- ==========================================

ALTER TABLE public.program_bimbel ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.peserta_bimbel ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bimbel_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bimbel_progress ENABLE ROW LEVEL SECURITY;

-- 1. Kebijakan Program Bimbel
CREATE POLICY "Public read program bimbel" ON public.program_bimbel FOR SELECT USING (true);
CREATE POLICY "OP manage program bimbel" ON public.program_bimbel FOR ALL USING (
    EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.code = 'OP')
);

-- 2. Kebijakan Peserta Bimbel
CREATE POLICY "Public read peserta bimbel" ON public.peserta_bimbel FOR SELECT USING (true);
CREATE POLICY "OP manage peserta bimbel" ON public.peserta_bimbel FOR ALL USING (
    EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.code = 'OP')
);

-- 3. Kebijakan Bimbel Sessions (Tutor bisa manage sesinya sendiri)
CREATE POLICY "Users can view sessions" ON public.bimbel_sessions FOR SELECT USING (true);
CREATE POLICY "Tutor can manage own sessions" ON public.bimbel_sessions FOR ALL USING (
    EXISTS (SELECT 1 FROM public.guru g WHERE g.user_id = auth.uid() AND g.id = teacher_id)
);

-- 4. Kebijakan Bimbel Progress (Tutor bisa manage progress siswanya)
CREATE POLICY "Users can view progress" ON public.bimbel_progress FOR SELECT USING (true);
CREATE POLICY "Tutor can manage own progress" ON public.bimbel_progress FOR ALL USING (
    EXISTS (
        SELECT 1 FROM public.bimbel_sessions s
        JOIN public.guru g ON g.id = s.teacher_id
        WHERE g.user_id = auth.uid() AND s.id = session_id
    )
);
