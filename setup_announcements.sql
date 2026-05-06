-- ==========================================
-- ADDON: ANNOUNCEMENT MODULE (D-PNG)
-- ==========================================

-- Table for Announcements
CREATE TABLE IF NOT EXISTS public.announcements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    target_role VARCHAR(50) NOT NULL, -- 'ALL', 'GM', 'OT', etc.
    created_by UUID REFERENCES public.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;

-- Policies
-- 1. Everyone can read announcements targeted at them or 'ALL'
CREATE POLICY "Users can view relevant announcements" ON public.announcements
    FOR SELECT USING (
        target_role = 'ALL' OR 
        target_role = (
            SELECT r.code 
            FROM public.user_roles ur 
            JOIN public.roles r ON ur.role_id = r.id 
            WHERE ur.user_id = auth.uid() AND ur.is_primary = true
            LIMIT 1
        )
    );

-- 2. Only creators (Headmaster/Teacher for class) can insert/update/delete their own
CREATE POLICY "Creators can manage their announcements" ON public.announcements
    FOR ALL USING (auth.uid() = created_by);

-- 3. Headmaster (KM) can manage all announcements? 
-- Based on the request, Headmaster is the primary announcer.
CREATE POLICY "Headmaster can manage all announcements" ON public.announcements
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.user_roles ur
            JOIN public.roles r ON ur.role_id = r.id
            WHERE ur.user_id = auth.uid() AND r.code = 'KM'
        )
    );
