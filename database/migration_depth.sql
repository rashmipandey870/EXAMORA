USE examora;

-- ==========================================
-- 1. DATABASE SCHEMA EXTENSIONS
-- ==========================================

-- Extend Users table to hold student profile backgrounds
ALTER TABLE users 
ADD COLUMN background VARCHAR(100) NULL,
ADD COLUMN goal VARCHAR(100) NULL,
ADD COLUMN target_timeline VARCHAR(100) NULL;

-- Extend Exams table for catalog detail depth and structured recommendation logic
ALTER TABLE exams
ADD COLUMN conducting_body VARCHAR(255) NULL,
ADD COLUMN eligibility_criteria TEXT NULL,
ADD COLUMN min_education_level VARCHAR(100) DEFAULT 'ANY',
ADD COLUMN eligible_streams VARCHAR(255) DEFAULT 'ANY',
ADD COLUMN goal_tags VARCHAR(255) DEFAULT 'ANY',
ADD COLUMN exam_pattern_summary TEXT NULL,
ADD COLUMN typical_application_window VARCHAR(255) NULL,
ADD COLUMN typical_exam_date_window VARCHAR(255) NULL,
ADD COLUMN official_website_url VARCHAR(512) NULL,
ADD COLUMN syllabus_availability_status VARCHAR(50) DEFAULT 'UNVERIFIED',
ADD COLUMN last_verified_at TIMESTAMP NULL DEFAULT NULL,
ADD COLUMN is_rolling_exam BOOLEAN DEFAULT FALSE,
ADD COLUMN is_verified_dates BOOLEAN DEFAULT FALSE;

-- Create Deadline Events table
CREATE TABLE IF NOT EXISTS deadline_events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    exam_id INT NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    event_date DATE NOT NULL,
    is_estimated BOOLEAN DEFAULT FALSE,
    source VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Units/Chapters table to group Topics
CREATE TABLE IF NOT EXISTS units (
    id INT AUTO_INCREMENT PRIMARY KEY,
    subject_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Extend Topics table with unit links
ALTER TABLE topics
ADD COLUMN unit_id INT NULL,
ADD COLUMN why_it_matters VARCHAR(512) NULL,
ADD CONSTRAINT fk_topics_unit FOREIGN KEY (unit_id) REFERENCES units(id) ON DELETE SET NULL;

-- Consolidate Weightage into Topic Trends table (exam-specific)
ALTER TABLE topic_trends
ADD COLUMN weightage DECIMAL(5, 2) DEFAULT 0.00;

-- Create Sub-topics / Concepts table
CREATE TABLE IF NOT EXISTS sub_topics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    topic_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Topic Prerequisites table
CREATE TABLE IF NOT EXISTS topic_prerequisites (
    topic_id INT NOT NULL,
    prerequisite_topic_id INT NOT NULL,
    PRIMARY KEY (topic_id, prerequisite_topic_id),
    FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE,
    FOREIGN KEY (prerequisite_topic_id) REFERENCES topics(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Extend Notes table to support structured AI learning content
ALTER TABLE notes
ADD COLUMN plain_explanation TEXT NULL,
ADD COLUMN core_concepts TEXT NULL,
ADD COLUMN key_formulas TEXT NULL,
ADD COLUMN worked_examples TEXT NULL,
ADD COLUMN common_mistakes TEXT NULL,
ADD COLUMN quick_summary TEXT NULL,
ADD COLUMN rating_sum INT DEFAULT 0,
ADD COLUMN rating_count INT DEFAULT 0;

-- Create Previous Year Questions (PYQ) Bank table
CREATE TABLE IF NOT EXISTS pyq_questions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    exam_id INT NOT NULL,
    subject_id INT NOT NULL,
    topic_id INT NOT NULL,
    year INT NOT NULL,
    question_text TEXT NOT NULL,
    options_json TEXT,
    correct_answer VARCHAR(255) NOT NULL,
    explanation TEXT,
    difficulty VARCHAR(50) DEFAULT 'MEDIUM',
    marks DECIMAL(4, 2) DEFAULT 1.00,
    is_verified BOOLEAN DEFAULT FALSE,
    source VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- 2. SEED METADATA FOR RECOMMENDATIONS
-- ==========================================

UPDATE exams SET
    conducting_body = 'IIT Guwahati',
    eligibility_criteria = 'Bachelor\'s degree in Engineering/Technology (4 years) or Master\'s degree in Science/Computer Applications.',
    min_education_level = 'GRADUATION',
    eligible_streams = 'B_TECH_CSE',
    goal_tags = 'HIGHER_STUDIES,GOVT_JOB',
    exam_pattern_summary = '3 hours, 65 questions, 100 marks. Multiple Choice (MCQ), Multiple Select (MSQ), and Numerical Answer Type (NAT).',
    typical_application_window = 'September - October',
    typical_exam_date_window = 'February',
    official_website_url = 'https://gate.iitg.ac.in',
    syllabus_availability_status = 'VERIFIED',
    is_rolling_exam = FALSE,
    is_verified_dates = FALSE
WHERE name = 'GATE CSE';

UPDATE exams SET
    conducting_body = 'National Testing Agency (NTA)',
    eligibility_criteria = 'Class 12/equivalent examination passed with Physics, Chemistry, and Mathematics.',
    min_education_level = 'HIGH_SCHOOL',
    eligible_streams = 'CLASS_12_PCM',
    goal_tags = 'HIGHER_STUDIES',
    exam_pattern_summary = '3 hours, MCQ and numerical answer type questions testing Physics, Chemistry, and Math.',
    typical_application_window = 'November - December',
    typical_exam_date_window = 'January and April',
    official_website_url = 'https://jeemain.nta.ac.in',
    syllabus_availability_status = 'VERIFIED',
    is_rolling_exam = FALSE,
    is_verified_dates = FALSE
WHERE name = 'JEE Main';

UPDATE exams SET
    conducting_body = 'Indian Institutes of Management (IIMs)',
    eligibility_criteria = 'Bachelor\'s Degree with at least 50% marks or equivalent CGPA.',
    min_education_level = 'GRADUATION',
    eligible_streams = 'B_TECH_CSE,B_TECH_STEM,COMMERCE,SCIENCE_GRAD,WORKING_PROFESSIONAL',
    goal_tags = 'HIGHER_STUDIES',
    exam_pattern_summary = '2 hours, 66 questions across Verbal Ability (VARC), Data Interpretation (DILR), and Quantitative Aptitude (QA).',
    typical_application_window = 'August - September',
    typical_exam_date_window = 'November',
    official_website_url = 'https://iimcat.ac.in',
    syllabus_availability_status = 'VERIFIED',
    is_rolling_exam = FALSE,
    is_verified_dates = FALSE
WHERE name = 'CAT';

UPDATE exams SET
    conducting_body = 'Union Public Service Commission',
    eligibility_criteria = 'Graduate degree in any discipline from a recognized university.',
    min_education_level = 'GRADUATION',
    eligible_streams = 'B_TECH_CSE,B_TECH_STEM,COMMERCE,SCIENCE_GRAD,WORKING_PROFESSIONAL',
    goal_tags = 'GOVT_JOB',
    exam_pattern_summary = 'Three stages: Preliminary (objective), Mains (written/subjective), and Personality Test (interview).',
    typical_application_window = 'February - March',
    typical_exam_date_window = 'May - June',
    official_website_url = 'https://upsc.gov.in',
    syllabus_availability_status = 'VERIFIED',
    is_rolling_exam = FALSE,
    is_verified_dates = FALSE
WHERE name = 'UPSC CSE';

-- Insert rolling exam AWS certification
INSERT INTO exams (name, exam_year, exam_date, is_custom, conducting_body, eligibility_criteria, min_education_level, eligible_streams, goal_tags, exam_pattern_summary, typical_application_window, typical_exam_date_window, official_website_url, syllabus_availability_status, is_rolling_exam, is_verified_dates) VALUES
('AWS Certified Solutions Architect', 2027, '2027-12-31', FALSE, 'Amazon Web Services (AWS)', 'No prerequisite qualification requirements. Recommended 1+ years design experience.', 'ANY', 'B_TECH_CSE,B_TECH_STEM,WORKING_PROFESSIONAL', 'CERTIFICATION', '130 minutes, 65 questions (multiple choice or multiple response). Pass score 720/1000.', 'Rolling / On-Demand', 'Any day of the year', 'https://aws.amazon.com/certification/certified-solutions-architect-associate', 'VERIFIED', TRUE, TRUE);

-- ==========================================
-- 3. SEEDING HIGH-DEPTH GATE CSE DBMS SYLLABUS
-- ==========================================

SET @gate_id = (SELECT id FROM exams WHERE name = 'GATE CSE' LIMIT 1);
SET @dbms_id = (SELECT id FROM subjects WHERE name = 'Database Management Systems (DBMS)' AND exam_id = @gate_id LIMIT 1);

-- Seed Units under DBMS
INSERT INTO units (subject_id, name) VALUES
(@dbms_id, 'Relational Database Design'),
(@dbms_id, 'Transaction Management');

SET @design_unit_id = (SELECT id FROM units WHERE name = 'Relational Database Design' AND subject_id = @dbms_id LIMIT 1);
SET @trans_unit_id = (SELECT id FROM units WHERE name = 'Transaction Management' AND subject_id = @dbms_id LIMIT 1);

-- Link existing topics to units and seed metadata
UPDATE topics SET 
    unit_id = @design_unit_id,
    why_it_matters = 'Standard core SQL & algebra. Forms the basis of 15% of all DBMS exam questions.'
WHERE name = 'Relational Algebra & SQL' AND subject_id = @dbms_id;

UPDATE topics SET 
    unit_id = @design_unit_id,
    why_it_matters = 'Core normalization theory. Highly logical, clean, and appears in almost every GATE cycle.'
WHERE name = 'Normalization' AND subject_id = @dbms_id;

UPDATE topics SET 
    unit_id = @trans_unit_id,
    why_it_matters = 'Frequently combined with locking protocols; essential for conceptual questions.'
WHERE name = 'Transactions & Concurrency Control' AND subject_id = @dbms_id;

-- Seed sub-topics
SET @tcc_topic_id = (SELECT id FROM topics WHERE name = 'Transactions & Concurrency Control' AND subject_id = @dbms_id LIMIT 1);
SET @norm_topic_id = (SELECT id FROM topics WHERE name = 'Normalization' AND subject_id = @dbms_id LIMIT 1);
SET @sql_topic_id = (SELECT id FROM topics WHERE name = 'Relational Algebra & SQL' AND subject_id = @dbms_id LIMIT 1);

INSERT INTO sub_topics (topic_id, name, description) VALUES
(@tcc_topic_id, 'Two-Phase Locking (2PL)', 'Basic 2PL rules for growing and shrinking phases, proving serializability but prone to deadlocks.'),
(@tcc_topic_id, 'Strict 2PL', 'Refinement where all exclusive locks are held until transaction commit, guaranteeing recoverability.'),
(@tcc_topic_id, 'Wait-Die Scheme', 'Non-preemptive deadlock prevention protocol using transaction timestamps.');

-- Seed Prerequisite: Normalization requires Relational Algebra & SQL
INSERT INTO topic_prerequisites (topic_id, prerequisite_topic_id) VALUES
(@norm_topic_id, @sql_topic_id);

-- Consolidate weightage in topic_trends
UPDATE topic_trends SET weightage = 8.00 WHERE topic_id = @sql_topic_id;
UPDATE topic_trends SET weightage = 4.00 WHERE topic_id = @norm_topic_id;
UPDATE topic_trends SET weightage = 5.00 WHERE topic_id = @tcc_topic_id;

-- Seed structured Notes for Transactions & Concurrency Control
INSERT INTO notes (topic_id, content_html, plain_explanation, core_concepts, key_formulas, worked_examples, common_mistakes, quick_summary) VALUES
(@tcc_topic_id, 
 '<h3>Transactions & Concurrency Control Notes</h3><p>Detailed notes covering transaction management...</p>',
 'A transaction is a logical unit of database processing. To maintain consistency, DBMS systems use scheduler algorithms like Two-Phase Locking to prevent anomalies when multiple users read and write concurrently.',
 '["ACID Properties: Atomicity, Consistency, Isolation, Durability", "Serializability: Conflict and View serializability checks", "Lock Types: Shared (S) and Exclusive (X) locks", "Concurrency Anomalies: Dirty read, Unrepeatable read, Lost Update"]',
 '["Conflict Serializability: If precedence graph has no cycles, schedule is conflict serializable.", "Growing Phase: Only acquire locks.", "Shrinking Phase: Only release locks."]',
 '["Example 1: Precedence Graph check. Given S = R1(A); W2(A); R1(B); W1(A); Commit1; Commit2. Since R1(A) -> W2(A) creates an edge T1 -> T2, and W2(A) -> W1(A) creates an edge T2 -> T1, there is a cycle. Hence, not conflict serializable.", "Example 2: Lock conversion. In 2PL, lock conversion (upgrading S to X) is permitted in the growing phase."]',
 '["Thinking 2PL prevents deadlocks. In reality, basic 2PL guarantees serializability but does NOT prevent deadlocks.", "Confusing Strict 2PL with Rigorous 2PL. Rigorous 2PL holds ALL locks until commit, while Strict 2PL only holds exclusive (X) locks until commit."]',
 '["1. Transactions must be ACID-compliant.", "2. Precedence graph cycle detection checks for conflict serializability.", "3. 2PL ensures conflict serializability but can deadlock.", "4. Strict 2PL avoids cascading rollbacks by holding exclusive locks.", "5. Wait-Die is non-preemptive deadlock prevention based on timestamp seniority."]'
);

-- ==========================================
-- 4. SEED DETAILED PYQ QUESTIONS
-- ==========================================

-- Insert PYQs for Relational Algebra & SQL
INSERT INTO pyq_questions (exam_id, subject_id, topic_id, year, question_text, options_json, correct_answer, explanation, difficulty, marks, is_verified, source) VALUES
(@gate_id, @dbms_id, @sql_topic_id, 2024, 'Given a relational schema R(A, B, C, D) and SQL query: SELECT A, SUM(B) FROM R GROUP BY A HAVING SUM(B) > 10. What is the execution order of clauses?', '["FROM, GROUP BY, HAVING, SELECT", "FROM, SELECT, GROUP BY, HAVING", "SELECT, FROM, GROUP BY, HAVING", "FROM, HAVING, GROUP BY, SELECT"]', 'FROM, GROUP BY, HAVING, SELECT', 'The logical query processing phase order is: FROM first, then WHERE (if any), then GROUP BY, then HAVING, then SELECT, and finally ORDER BY.', 'MEDIUM', 1.00, TRUE, 'GATE CSE 2024 Question 12'),
(@gate_id, @dbms_id, @sql_topic_id, 2023, 'Which of the following relational algebra expressions yields the set difference of relations R and S?', '["R - S", "R Intersection S", "R Union S", "R Cartesian Product S"]', 'R - S', 'Set difference operation returns tuples present in R but not in S. Represented as R - S.', 'EASY', 1.00, TRUE, 'GATE CSE 2023 Question 5');

-- Insert PYQs for Normalization
INSERT INTO pyq_questions (exam_id, subject_id, topic_id, year, question_text, options_json, correct_answer, explanation, difficulty, marks, is_verified, source) VALUES
(@gate_id, @dbms_id, @norm_topic_id, 2022, 'Consider relation R(A, B, C, D, E) with FDs: A->B, BC->D, E->A. What is the primary candidate key of R?', '["{E, C}", "{A, C}", "{B, C}", "{C, D}"]', '{E, C}', 'Calculating attribute closure: {E,C}+ = {E,C,A,B,D}. Since it contains all attributes of the relation, {E,C} is the minimal candidate key.', 'MEDIUM', 2.00, TRUE, 'GATE CSE 2022 Question 34');

-- Insert PYQs for Transactions & Concurrency Control
INSERT INTO pyq_questions (exam_id, subject_id, topic_id, year, question_text, options_json, correct_answer, explanation, difficulty, marks, is_verified, source) VALUES
(@gate_id, @dbms_id, @tcc_topic_id, 2025, 'Under the Wait-Die deadlock prevention scheme, what happens if an older transaction T_old requests a lock held by a younger transaction T_young?', '["T_old waits for T_young to release the lock", "T_old dies immediately", "T_young is aborted (killed)", "Both transactions enter deadlock rollback"]', 'T_old waits for T_young to release the lock', 'In Wait-Die, older transactions are allowed to wait for younger ones (Old waits, Young dies). Therefore, T_old waits.', 'HARD', 2.00, TRUE, 'GATE CSE 2025 Question 48');
