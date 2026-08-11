-- EXAMORA Database Migration - Phase 17.3 (Attempt Tracking)
-- CREATE attempts tracking table to save student answer submissions

CREATE TABLE IF NOT EXISTS pyq_attempts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    question_id INT NOT NULL,
    selected_option VARCHAR(255) NOT NULL,
    is_correct BOOLEAN NOT NULL,
    attempted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES pyq_questions(id) ON DELETE CASCADE
);
