-- SQL Setup for Finance Module
-- This file defines the tables needed for SPP, Savings, Other Fees, and Operational Expenses.

-- 1. Table for SPP Records
CREATE TABLE IF NOT EXISTS spp_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES siswa(id) ON DELETE CASCADE,
    amount DECIMAL(12, 2) NOT NULL,
    month VARCHAR(20) NOT NULL,
    year VARCHAR(4) NOT NULL,
    status VARCHAR(20) DEFAULT 'belum' CHECK (status IN ('lunas', 'belum', 'cicilan')),
    paid_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Table for Student Savings
CREATE TABLE IF NOT EXISTS savings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES siswa(id) ON DELETE CASCADE,
    amount DECIMAL(12, 2) NOT NULL,
    type VARCHAR(10) CHECK (type IN ('setor', 'tarik')),
    saved_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Table for Other Fees (Tagihan Lainnya)
CREATE TABLE IF NOT EXISTS other_fees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES siswa(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    due_date TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'belum' CHECK (status IN ('lunas', 'belum')),
    paid_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Table for Operational Expenses
CREATE TABLE IF NOT EXISTS operational_expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    description TEXT NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    category VARCHAR(100),
    date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Table for SPP Configuration (Nominal per level)
CREATE TABLE IF NOT EXISTS spp_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    level VARCHAR(20) NOT NULL UNIQUE, -- e.g., '10', '11', '12'
    amount DECIMAL(12, 2) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Initial Data for SPP Config
INSERT INTO spp_config (level, amount) VALUES 
('10', 250000),
('11', 250000),
('12', 250000)
ON CONFLICT (level) DO NOTHING;

-- 5. Optional: View for ease of join (Optional as we can join in Flutter)
-- CREATE VIEW view_spp_with_student AS
-- SELECT s.*, sw.nama as student_name
-- FROM spp_records s
-- JOIN siswa sw ON s.student_id = sw.id;
