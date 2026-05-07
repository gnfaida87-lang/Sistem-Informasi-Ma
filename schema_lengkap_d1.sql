-- SCHEMA LENGKAP SISTEM INFORMASI MADRASAH (CLOUDFLARE D1 / SQLITE)
-- Versi: 2.0 (Migrated from Supabase)

-- 1. Tabel Users
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    is_active INTEGER DEFAULT 1,
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
    score REAL,
    type TEXT, -- UTS, UAS, FINAL
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
    status TEXT, -- hadir, izin, sakit, alpha
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

-- 14. DATA AWAL (SEEDING) - ROLE
INSERT OR IGNORE INTO roles (id, code, nama) VALUES 
('r1', 'SA', 'Super Admin'),
('r2', 'KM', 'Kepala Madrasah'),
('r3', 'WK', 'Wakil Kepala'),
('r4', 'OP', 'Operator'),
('r5', 'AK', 'Admin Keuangan'),
('r6', 'GM', 'Guru Mapel'),
('r7', 'GB', 'Guru BK'),
('r8', 'OT', 'Orang Tua');

-- 15. USER ADMIN DEFAULT (Username: admin, Password: password123)
-- Password hash di bawah adalah dummy, sesuaikan dengan logic D1Service Anda
INSERT OR IGNORE INTO users (id, username, email, password_hash) VALUES 
('u1', 'admin', 'admin@madrasah.sch.id', 'password123');

INSERT OR IGNORE INTO user_roles (user_id, role_id, is_primary) VALUES 
('u1', 'r1', 1);
