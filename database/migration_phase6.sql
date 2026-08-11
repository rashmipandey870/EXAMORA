USE examora;

-- 1. Add completed_at column to study_tasks to support consistency streaks
ALTER TABLE study_tasks ADD COLUMN completed_at TIMESTAMP NULL DEFAULT NULL;

-- 2. Backfill completed_at for existing completed tasks (if any)
UPDATE study_tasks SET completed_at = CURRENT_TIMESTAMP WHERE status = 'COMPLETED' AND completed_at IS NULL;

-- 3. Shift active study plan for user 1 (rashmi_test) to start 4 days ago for visual verification
UPDATE study_plans SET start_date = DATE_SUB(CURDATE(), INTERVAL 4 DAY) WHERE user_id = 1 AND status = 'ACTIVE';

-- Find min scheduled date for user 1's plan
SET @min_date = (SELECT MIN(scheduled_date) FROM study_tasks t JOIN study_plans p ON t.study_plan_id = p.id WHERE p.user_id = 1 AND p.status = 'ACTIVE');

-- Shift all task dates to align with the new start date
UPDATE study_tasks t
JOIN study_plans p ON t.study_plan_id = p.id
SET t.scheduled_date = DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 4 DAY), INTERVAL DATEDIFF(t.scheduled_date, @min_date) DAY)
WHERE p.user_id = 1 AND p.status = 'ACTIVE';

-- Seed past study history to create streak and weekly performance metrics
-- We mark tasks scheduled before today as COMPLETED and set their completed_at timestamp
UPDATE study_tasks t
JOIN study_plans p ON t.study_plan_id = p.id
SET t.status = 'COMPLETED',
    t.completed_hours = t.scheduled_hours,
    t.completed_at = CAST(t.scheduled_date AS DATETIME)
WHERE p.user_id = 1 
  AND p.status = 'ACTIVE'
  AND t.scheduled_date < CURDATE()
  AND t.is_mock_test = FALSE;
