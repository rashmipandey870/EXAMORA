-- EXAMORA Database Migration - Phase 17.5 (PYQ Year Coverage Tracking)
-- CREATE pyq_year_coverage register table and seed initial subject coverage

CREATE TABLE IF NOT EXISTS pyq_year_coverage (
    id INT AUTO_INCREMENT PRIMARY KEY,
    exam_id INT NOT NULL,
    subject_id INT NOT NULL,
    year INT NOT NULL,
    question_count INT DEFAULT 0,
    verified_count INT DEFAULT 0,
    source_url VARCHAR(255) NULL,
    ingestion_status VARCHAR(50) DEFAULT 'NOT_STARTED',
    FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    UNIQUE KEY unique_exam_sub_yr (exam_id, subject_id, year)
);

-- Seed honest coverage values for GATE CSE (Exam 1) and DBMS (Subject 1)
-- Verified counts set to 0 as all existing seeds are unverified exam-style practice questions
INSERT INTO pyq_year_coverage (exam_id, subject_id, year, question_count, verified_count, source_url) VALUES 
(1, 1, 2026, 8, 0, 'https://gate2027.iitm.ac.in'),
(1, 1, 2025, 7, 0, 'https://gate2027.iitm.ac.in'),
(1, 1, 2024, 6, 0, 'https://gate2027.iitm.ac.in'),
(1, 1, 2023, 9, 0, 'https://gate2027.iitm.ac.in');
