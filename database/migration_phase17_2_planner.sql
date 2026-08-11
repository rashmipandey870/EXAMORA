USE examora;

-- Add task_mode column to study_tasks table if it doesn't exist
ALTER TABLE study_tasks ADD COLUMN task_mode VARCHAR(50) DEFAULT 'LEARN';
