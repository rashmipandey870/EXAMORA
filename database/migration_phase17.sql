USE examora;

-- Create Topic Notes Cache table
CREATE TABLE IF NOT EXISTS topic_notes (
    topic_id INT PRIMARY KEY,
    notes_content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
