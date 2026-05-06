-- ==========================================
-- MIGRASI: CATATAN PERKEMBANGAN KELAS
-- ==========================================

-- 1. Tabel Catatan Perkembangan Kelas (Hanya untuk Wali Kelas)
CREATE TABLE IF NOT EXISTS public.catatan_perkembangan (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    kelas_id UUID REFERENCES public.kelas(id) ON DELETE CASCADE,
    guru_id UUID REFERENCES public.guru(id) ON DELETE CASCADE, -- Harus Wali Kelas
    tanggal DATE DEFAULT CURRENT_DATE,
    kategori VARCHAR(50), -- e.g. 'Akademik', 'Kedisiplinan', 'Event'
    catatan TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. RLS Policies untuk Catatan Perkembangan
ALTER TABLE public.catatan_perkembangan ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Wali Kelas can manage own class notes" ON public.catatan_perkembangan
FOR ALL USING (
    EXISTS (
        SELECT 1 FROM public.kelas k
        JOIN public.guru g ON g.id = k.wali_kelas_id
        WHERE g.user_id = auth.uid() AND k.id = public.catatan_perkembangan.kelas_id
    )
);

CREATE POLICY "Public Read class notes" ON public.catatan_perkembangan
FOR SELECT USING (true);
