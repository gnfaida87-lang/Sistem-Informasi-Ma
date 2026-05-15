-- SCHEMA LENGKAP SISTEM INFORMASI MADRASAH (CLOUDFLARE D1 / SQLITE)
-- Versi: 2.0 (Migrated from Supabase)

-- 1. Tabel Users
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    full_name TEXT,
    nis_nip TEXT,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    is_active INTEGER DEFAULT 1,
    profile_url TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabel Roles
CREATE TABLE IF NOT EXISTS roles (
    id TEXT PRIMARY KEY,
    code TEXT UNIQUE NOT NULL, -- SA, KM, WK, OP, AK, GM, GB, OT, ST
    nama TEXT NOT NULL
);

-- 3. Tabel User Roles (Link User ke Role)
CREATE TABLE IF NOT EXISTS user_roles (
    user_id TEXT,
    role_id TEXT,
    is_primary INTEGER DEFAULT 0,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

-- 4. Tabel Teachers (Guru)
CREATE TABLE IF NOT EXISTS teachers (
    id TEXT PRIMARY KEY,
    user_id TEXT UNIQUE,
    nip TEXT UNIQUE,
    name TEXT NOT NULL,
    is_wali_kelas INTEGER DEFAULT 0,
    is_active INTEGER DEFAULT 1,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 5. Tabel Classes (Kelas)
CREATE TABLE IF NOT EXISTS classes (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    teacher_id TEXT, -- Wali Kelas
    FOREIGN KEY (teacher_id) REFERENCES teachers(id)
);

-- 6. Tabel Students (Siswa)
CREATE TABLE IF NOT EXISTS students (
    id TEXT PRIMARY KEY,
    user_id TEXT UNIQUE,
    nis TEXT UNIQUE,
    name TEXT NOT NULL,
    class_id TEXT,
    is_active INTEGER DEFAULT 1,
    status TEXT DEFAULT 'active',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (class_id) REFERENCES classes(id)
);

-- 7. Tabel Subjects (Mata Pelajaran)
CREATE TABLE IF NOT EXISTS subjects (
    id TEXT PRIMARY KEY,
    code TEXT UNIQUE,
    name TEXT NOT NULL,
    min_score REAL DEFAULT 75.0
);

-- 8. Tabel Academic Years (Tahun Ajaran)
CREATE TABLE IF NOT EXISTS academic_years (
    id TEXT PRIMARY KEY,
    year_name TEXT NOT NULL, -- Contoh: 2023/2024
    semester TEXT NOT NULL,  -- Ganjil / Genap
    is_active INTEGER DEFAULT 0
);

-- 9. Tabel Time Slots (Slot Waktu Jadwal)
CREATE TABLE IF NOT EXISTS time_slots (
    id TEXT PRIMARY KEY,
    day TEXT NOT NULL, -- Senin, Selasa, dst
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL
);

-- 10. Tabel Teaching Schedules (Jadwal Pelajaran)
CREATE TABLE IF NOT EXISTS teaching_schedules (
    id TEXT PRIMARY KEY,
    academic_year_id TEXT,
    class_id TEXT,
    subject_id TEXT,
    teacher_id TEXT,
    time_slot_id TEXT,
    UNIQUE(academic_year_id, class_id, time_slot_id),
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(id),
    FOREIGN KEY (class_id) REFERENCES classes(id),
    FOREIGN KEY (subject_id) REFERENCES subjects(id),
    FOREIGN KEY (teacher_id) REFERENCES teachers(id),
    FOREIGN KEY (time_slot_id) REFERENCES time_slots(id)
);

-- 11. Tabel Student Grades (Nilai)
CREATE TABLE IF NOT EXISTS student_grades (
    id TEXT PRIMARY KEY,
    student_id TEXT,
    subject_id TEXT,
    semester_id TEXT,
    score REAL CHECK (score >= 0 AND score <= 100),
    type TEXT CHECK (type IN ('UTS', 'UAS', 'PAS', 'FINAL', 'HARIAN')),
    UNIQUE(student_id, subject_id, semester_id, type),
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (subject_id) REFERENCES subjects(id),
    FOREIGN KEY (semester_id) REFERENCES academic_years(id)
);

-- 12. Tabel Attendance (Absensi)
CREATE TABLE IF NOT EXISTS attendance (
    id TEXT PRIMARY KEY,
    student_id TEXT,
    class_id TEXT,
    teacher_id TEXT,
    date TEXT,
    status TEXT CHECK (status IN ('hadir', 'izin', 'sakit', 'alpha')),
    notes TEXT,
    UNIQUE(student_id, date),
    FOREIGN KEY (student_id) REFERENCES students(id)
);

-- 13. Tabel Announcements (Pengumuman)
CREATE TABLE IF NOT EXISTS announcements (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    target_role TEXT DEFAULT 'all',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 14. Tabel System Settings
CREATE TABLE IF NOT EXISTS system_settings (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    school_name TEXT NOT NULL DEFAULT 'SI Madrasah',
    headmaster_name TEXT NOT NULL DEFAULT 'H. Ahmad Syaifuddin, M.Pd',
    logo_url TEXT,
    favicon_url TEXT,
    guru_ai_keys TEXT DEFAULT '[]',
    guru_ai_engine TEXT DEFAULT 'OpenAI (GPT-4o)',
    belajar_ai_keys TEXT DEFAULT '[]',
    belajar_ai_engine TEXT DEFAULT 'Gemini (1.5 Pro)',
    is_maintenance INTEGER DEFAULT 0,
    gdrive_api_key TEXT,
    gdrive_folder_id TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 15. Tabel Departments (Jurusan)
CREATE TABLE IF NOT EXISTS departments (
    id TEXT PRIMARY KEY,
    kode TEXT UNIQUE,
    nama TEXT NOT NULL
);

-- 16. Tabel Semesters
CREATE TABLE IF NOT EXISTS semesters (
    id TEXT PRIMARY KEY,
    tahun_ajaran_id TEXT,
    nama TEXT NOT NULL, -- Ganjil / Genap
    is_active INTEGER DEFAULT 0,
    kkm_default REAL DEFAULT 75.0,
    is_validated INTEGER DEFAULT 0,
    validated_by TEXT,
    FOREIGN KEY (tahun_ajaran_id) REFERENCES academic_years(id)
);

-- 17. Tabel Ekskul
CREATE TABLE IF NOT EXISTS ekskul (
    id TEXT PRIMARY KEY,
    nama TEXT NOT NULL,
    pembina TEXT
);

-- 18. Tabel Ekskul Participants
CREATE TABLE IF NOT EXISTS ekskul_participants (
    id TEXT PRIMARY KEY,
    ekskul_id TEXT,
    siswa_id TEXT,
    FOREIGN KEY (ekskul_id) REFERENCES ekskul(id),
    FOREIGN KEY (siswa_id) REFERENCES students(id)
);

-- 19. Tabel Bimbel Programs
CREATE TABLE IF NOT EXISTS bimbel_programs (
    id TEXT PRIMARY KEY,
    nama TEXT NOT NULL,
    guru_id TEXT,
    FOREIGN KEY (guru_id) REFERENCES teachers(id)
);

-- 20. Tabel Bimbel Participants
CREATE TABLE IF NOT EXISTS bimbel_participants (
    id TEXT PRIMARY KEY,
    program_id TEXT,
    siswa_id TEXT,
    status TEXT DEFAULT 'active',
    FOREIGN KEY (program_id) REFERENCES bimbel_programs(id),
    FOREIGN KEY (siswa_id) REFERENCES students(id)
);

-- 21. Tabel Bimbel Sessions
CREATE TABLE IF NOT EXISTS bimbel_sessions (
    id TEXT PRIMARY KEY,
    program_id TEXT,
    teacher_id TEXT,
    topic TEXT,
    session_date TEXT,
    duration_minutes INTEGER DEFAULT 60,
    FOREIGN KEY (program_id) REFERENCES bimbel_programs(id),
    FOREIGN KEY (teacher_id) REFERENCES teachers(id)
);

-- 22. Tabel Bimbel Progress (Nilai & Absensi per Sesi)
CREATE TABLE IF NOT EXISTS bimbel_progress (
    id TEXT PRIMARY KEY,
    session_id TEXT,
    student_id TEXT,
    score REAL DEFAULT 0.0,
    notes TEXT,
    FOREIGN KEY (session_id) REFERENCES bimbel_sessions(id),
    FOREIGN KEY (student_id) REFERENCES students(id)
);

-- 23. Tabel Bimbel Materi
CREATE TABLE IF NOT EXISTS bimbel_materi (
    id TEXT PRIMARY KEY,
    program_id TEXT,
    type TEXT, -- PDF, Video, Link
    judul TEXT NOT NULL,
    url TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (program_id) REFERENCES bimbel_programs(id)
);

-- 24. Tabel Exam Schedules
CREATE TABLE IF NOT EXISTS exam_schedules (
    id TEXT PRIMARY KEY,
    exam_type TEXT,
    exam_name TEXT,
    semester TEXT,
    class_level TEXT,
    date_label TEXT,
    session_name TEXT,
    time_range TEXT,
    room_name TEXT,
    subject_name TEXT,
    supervisor_name TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 25. DATA AWAL (SEEDING) - ROLE
INSERT OR IGNORE INTO roles (id, code, nama) VALUES 
('r1', 'SA', 'Super Admin'),
('r2', 'KM', 'Kepala Madrasah'),
('r3', 'WK', 'Wakil Kepala'),
('r4', 'OP', 'Operator'),
('r5', 'AK', 'Admin Keuangan'),
('r6', 'GM', 'Guru Mapel'),
('r7', 'GB', 'Guru BK'),
('r8', 'OT', 'Orang Tua');

-- 26. DATA AWAL - SYSTEM SETTINGS
INSERT OR IGNORE INTO system_settings (id) VALUES (1);

-- 27. USER ADMIN DEFAULT (Username: admin, Password: password123)
INSERT OR IGNORE INTO users (id, username, email, password_hash) VALUES 
('u1', 'admin', 'admin@madrasah.sch.id', 'password123');

INSERT OR IGNORE INTO user_roles (user_id, role_id, is_primary) VALUES 
('u1', 'r1', 1);
