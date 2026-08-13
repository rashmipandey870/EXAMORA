USE examora;

-- 1. Register the full range of years for GATE CSE (Exam 1) & DBMS (Subject 1)
-- Placeholder years set source_url to NULL and question_count to 0
INSERT IGNORE INTO pyq_year_coverage (exam_id, subject_id, year, question_count, verified_count, source_url) VALUES
(1, 1, 2027, 0, 0, NULL),
(1, 1, 2022, 0, 0, NULL),
(1, 1, 2021, 0, 0, NULL),
(1, 1, 2020, 0, 0, NULL),
(1, 1, 2019, 0, 0, NULL),
(1, 1, 2018, 0, 0, NULL),
(1, 1, 2017, 0, 0, NULL),
(1, 1, 2016, 0, 0, NULL),
(1, 1, 2015, 0, 0, NULL),
(1, 1, 2014, 0, 0, NULL),
(1, 1, 2013, 0, 0, NULL),
(1, 1, 2012, 0, 0, NULL),
(1, 1, 2011, 0, 0, NULL),
(1, 1, 2010, 0, 0, NULL),
(1, 1, 2009, 0, 0, NULL),
(1, 1, 2008, 0, 0, NULL);

-- 2. Create the pyq_bookmarks table to persist flagged questions
CREATE TABLE IF NOT EXISTS pyq_bookmarks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    question_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES pyq_questions(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_question_bookmark (user_id, question_id)
);
