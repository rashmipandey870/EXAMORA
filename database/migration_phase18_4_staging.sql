USE examora;

CREATE TABLE IF NOT EXISTS pyq_pdf_staging (
    id INT AUTO_INCREMENT PRIMARY KEY,
    exam_id INT NOT NULL,
    subject_id INT NOT NULL,
    year INT NOT NULL,
    source_pdf_filename VARCHAR(255),
    source_url VARCHAR(512) NOT NULL,
    extracted_question_text TEXT,
    extracted_options_json TEXT,
    extracted_correct_answer VARCHAR(10),
    extracted_explanation TEXT,
    suggested_topic_id INT,
    suggested_difficulty VARCHAR(50),
    review_status VARCHAR(50) DEFAULT 'PENDING_REVIEW',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE
);
