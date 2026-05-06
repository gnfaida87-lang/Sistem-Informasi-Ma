-- ==========================================
-- TEACHER FEATURES MODULE (GURU MAPEL & BIMBEL)
-- ==========================================

-- 1. Table: Teaching Schedules (Simplified for Dashboard)
CREATE TABLE IF NOT EXISTS public.teaching_schedules (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    teacher_id UUID REFERENCES public.guru(id) ON DELETE CASCADE,
    subject_id UUID REFERENCES public.mapel(id) ON DELETE CASCADE,
    class_id UUID REFERENCES public.kelas(id) ON DELETE CASCADE,
    day VARCHAR(20) NOT NULL, -- 'Senin', 'Selasa', etc.
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Table: Bimbel Sessions
CREATE TABLE IF NOT EXISTS public.bimbel_sessions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    teacher_id UUID REFERENCES public.guru(id) ON DELETE CASCADE,
    topic VARCHAR(255) NOT NULL,
    session_date DATE NOT NULL,
    duration_minutes INT DEFAULT 60,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Table: Bimbel Progress
CREATE TABLE IF NOT EXISTS public.bimbel_progress (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    session_id UUID REFERENCES public.bimbel_sessions(id) ON DELETE CASCADE,
    student_id UUID REFERENCES public.siswa(id) ON DELETE CASCADE,
    notes TEXT,
    score INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(session_id, student_id)
);

-- ==========================================
-- RLS POLICIES
-- ==========================================

-- Teaching Schedules
ALTER TABLE public.teaching_schedules ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Teacher can view own schedule" ON public.teaching_schedules 
    FOR SELECT USING (auth.uid() IN (SELECT user_id FROM public.guru WHERE id = teacher_id));
CREATE POLICY "WK Manage Teaching Schedules" ON public.teaching_schedules 
    FOR ALL USING (EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.code = 'WK'));

-- Bimbel Sessions
ALTER TABLE public.bimbel_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Teacher can manage own bimbel sessions" ON public.bimbel_sessions 
    FOR ALL USING (auth.uid() IN (SELECT user_id FROM public.guru WHERE id = teacher_id));

-- Bimbel Progress
ALTER TABLE public.bimbel_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Teacher can manage own bimbel progress" ON public.bimbel_progress 
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.bimbel_sessions s 
            JOIN public.guru g ON s.teacher_id = g.id 
            WHERE s.id = session_id AND g.user_id = auth.uid()
        )
    );
