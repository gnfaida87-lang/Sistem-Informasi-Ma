-- ==========================================
-- MIGRASI: TAMBAH KONTAK ORANG TUA
-- ==========================================

-- 1. Tambah kolom no_hp ke tabel orang_tua
ALTER TABLE public.orang_tua ADD COLUMN IF NOT EXISTS no_hp VARCHAR(20);

-- 2. Tambah kolom kelas_id ke tabel guru (opsional tapi disarankan untuk performa)
ALTER TABLE public.guru ADD COLUMN IF NOT EXISTS kelas_id UUID REFERENCES public.kelas(id);

-- 3. Update Policy untuk Wali Kelas agar bisa melihat data siswa di kelasnya
CREATE POLICY "Wali Kelas can view students in their class" ON public.siswa
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.guru g
        JOIN public.kelas k ON k.wali_kelas_id = g.id
        WHERE g.user_id = auth.uid() AND k.id = public.siswa.kelas_id
    )
);

-- 4. Policy agar Wali Kelas bisa melihat data orang tua siswa di kelasnya
CREATE POLICY "Wali Kelas can view parents in their class" ON public.orang_tua
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.orang_tua_siswa ots
        JOIN public.siswa s ON s.id = ots.siswa_id
        JOIN public.kelas k ON k.id = s.kelas_id
        JOIN public.guru g ON g.id = k.wali_kelas_id
        WHERE g.user_id = auth.uid() AND public.orang_tua.id = ots.orang_tua_id
    )
);
