-- ============================================
--  Smart Surgery Scheduling System - Database
-- ============================================

CREATE DATABASE IF NOT EXISTS surgery_db;
USE surgery_db;

-- Users table (Admin, Doctor, Nurse)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    role ENUM('ADMIN', 'DOCTOR', 'NURSE') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Patients table
CREATE TABLE IF NOT EXISTS patients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    gender ENUM('MALE', 'FEMALE', 'OTHER') NOT NULL,
    blood_group VARCHAR(5),
    contact_number VARCHAR(15),
    address TEXT,
    -- Risk factors
    has_diabetes BOOLEAN DEFAULT FALSE,
    has_hypertension BOOLEAN DEFAULT FALSE,
    has_heart_disease BOOLEAN DEFAULT FALSE,
    has_kidney_disease BOOLEAN DEFAULT FALSE,
    is_smoker BOOLEAN DEFAULT FALSE,
    bmi DECIMAL(5,2),
    asa_grade INT DEFAULT 1 COMMENT '1=Healthy, 2=Mild, 3=Severe, 4=Life-threatening',
    medical_history TEXT,
    allergies TEXT,
    risk_score DECIMAL(5,2) DEFAULT 0.0,
    risk_level ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') DEFAULT 'LOW',
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Surgeons table
CREATE TABLE IF NOT EXISTS surgeons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    surgeon_id VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    qualification VARCHAR(200),
    experience_years INT DEFAULT 0,
    contact_number VARCHAR(15),
    email VARCHAR(100),
    is_available BOOLEAN DEFAULT TRUE,
    max_surgeries_per_day INT DEFAULT 3,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Operation Theaters table
CREATE TABLE IF NOT EXISTS operation_theaters (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ot_number VARCHAR(10) UNIQUE NOT NULL,
    ot_name VARCHAR(50) NOT NULL,
    ot_type ENUM('GENERAL', 'CARDIAC', 'NEURO', 'ORTHOPEDIC', 'EMERGENCY') NOT NULL,
    status ENUM('AVAILABLE', 'OCCUPIED', 'MAINTENANCE', 'STERILIZING') DEFAULT 'AVAILABLE',
    equipment_list TEXT,
    last_sterilized TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Surgeries table
CREATE TABLE IF NOT EXISTS surgeries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    surgery_ref VARCHAR(30) UNIQUE NOT NULL,
    patient_id INT NOT NULL,
    surgeon_id INT NOT NULL,
    ot_id INT NOT NULL,
    surgery_type VARCHAR(100) NOT NULL,
    surgery_category ENUM('ELECTIVE', 'URGENT', 'EMERGENCY') NOT NULL,
    priority_level ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') NOT NULL,
    scheduled_date DATE NOT NULL,
    scheduled_time TIME NOT NULL,
    estimated_duration INT NOT NULL COMMENT 'in minutes',
    status ENUM('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'POSTPONED') DEFAULT 'SCHEDULED',
    pre_op_notes TEXT,
    post_op_notes TEXT,
    complications TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id),
    FOREIGN KEY (surgeon_id) REFERENCES surgeons(id),
    FOREIGN KEY (ot_id) REFERENCES operation_theaters(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Surgeon availability/schedule table
CREATE TABLE IF NOT EXISTS surgeon_schedule (
    id INT AUTO_INCREMENT PRIMARY KEY,
    surgeon_id INT NOT NULL,
    available_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_blocked BOOLEAN DEFAULT FALSE,
    reason VARCHAR(200),
    FOREIGN KEY (surgeon_id) REFERENCES surgeons(id)
);

-- ============================================
--  SAMPLE DATA
-- ============================================

-- Default Users (passwords are bcrypt hashed)
-- admin123, doc123, nurse123
INSERT INTO users (username, password, full_name, email, role) VALUES
('admin',   '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lFDW', 'System Administrator', 'admin@surgery.com', 'ADMIN'),
('doctor1', '$2a$10$somehashedpassword1234567890abcdefghijklmno', 'Dr. Rahim Uddin', 'rahim@surgery.com', 'DOCTOR'),
('nurse1',  '$2a$10$somehashedpassword1234567890abcdefghijklmno', 'Nurse Fatema Begum', 'fatema@surgery.com', 'NURSE');

-- For quick testing, we'll insert with plain text equivalent check handled in code
DELETE FROM users;
INSERT INTO users (username, password, full_name, email, role) VALUES
('admin',   'admin123',  'System Administrator',    'admin@surgery.com',   'ADMIN'),
('doctor1', 'doc123',    'Dr. Rahim Uddin',          'rahim@surgery.com',   'DOCTOR'),
('doctor2', 'doc123',    'Dr. Priya Sharma',         'priya@surgery.com',   'DOCTOR'),
('nurse1',  'nurse123',  'Nurse Fatema Begum',        'fatema@surgery.com',  'NURSE');

-- Sample Surgeons
INSERT INTO surgeons (surgeon_id, full_name, specialization, qualification, experience_years, contact_number) VALUES
('SRG001', 'Dr. Rahim Uddin',      'General Surgery',     'MBBS, MS (Surgery)',          12, '01711000001'),
('SRG002', 'Dr. Priya Sharma',     'Cardiac Surgery',     'MBBS, MS, MCh (Cardiac)',     18, '01711000002'),
('SRG003', 'Dr. Karim Hossain',    'Orthopedic Surgery',  'MBBS, MS (Ortho)',            8,  '01711000003'),
('SRG004', 'Dr. Sunita Das',       'Neuro Surgery',       'MBBS, MS, MCh (Neuro)',       15, '01711000004'),
('SRG005', 'Dr. Mahbub Alam',      'Urology',             'MBBS, MS (Urology)',          10, '01711000005');

-- Sample Operation Theaters
INSERT INTO operation_theaters (ot_number, ot_name, ot_type, status) VALUES
('OT-01', 'General OT 1',     'GENERAL',     'AVAILABLE'),
('OT-02', 'General OT 2',     'GENERAL',     'AVAILABLE'),
('OT-03', 'Cardiac Suite',    'CARDIAC',     'AVAILABLE'),
('OT-04', 'Neuro Suite',      'NEURO',       'AVAILABLE'),
('OT-05', 'Ortho Suite',      'ORTHOPEDIC',  'MAINTENANCE'),
('OT-06', 'Emergency OT',     'EMERGENCY',   'AVAILABLE');

-- Sample Patients
INSERT INTO patients (patient_id, full_name, age, gender, blood_group, contact_number, has_diabetes, has_hypertension, asa_grade, bmi, risk_score, risk_level) VALUES
('PAT001', 'Mohammad Ali',        55, 'MALE',   'B+',  '01811000001', TRUE,  TRUE,  3, 28.5, 65.0, 'HIGH'),
('PAT002', 'Rashida Begum',       32, 'FEMALE', 'O+',  '01811000002', FALSE, FALSE, 1, 22.1, 10.0, 'LOW'),
('PAT003', 'Habibur Rahman',      68, 'MALE',   'A+',  '01811000003', TRUE,  TRUE,  4, 31.2, 85.0, 'CRITICAL'),
('PAT004', 'Kamrun Nahar',        45, 'FEMALE', 'AB+', '01811000004', FALSE, TRUE,  2, 25.8, 35.0, 'MEDIUM'),
('PAT005', 'Sohel Rana',          28, 'MALE',   'O-',  '01811000005', FALSE, FALSE, 1, 23.4, 8.0,  'LOW');

-- Sample Surgeries
INSERT INTO surgeries (surgery_ref, patient_id, surgeon_id, ot_id, surgery_type, surgery_category, priority_level, scheduled_date, scheduled_time, estimated_duration, status) VALUES
('SRY-2026-001', 1, 1, 1, 'Appendectomy',          'URGENT',    'HIGH',     '2026-04-23', '08:00:00', 90,  'SCHEDULED'),
('SRY-2026-002', 2, 1, 2, 'Laparoscopic Cholecystectomy', 'ELECTIVE', 'LOW', '2026-04-23', '10:30:00', 120, 'SCHEDULED'),
('SRY-2026-003', 3, 2, 3, 'Coronary Artery Bypass', 'URGENT',   'CRITICAL', '2026-04-23', '07:00:00', 240, 'IN_PROGRESS'),
('SRY-2026-004', 4, 3, 5, 'Knee Replacement',       'ELECTIVE',  'MEDIUM',  '2026-04-25', '09:00:00', 150, 'SCHEDULED'),
('SRY-2026-005', 5, 4, 4, 'Brain Tumor Resection',  'URGENT',    'HIGH',    '2026-04-24', '06:30:00', 300, 'SCHEDULED');
