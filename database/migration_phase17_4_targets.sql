-- EXAMORA Database Migration - Phase 17.4 (Student-Set Targets & Splits)
-- SAFE alteration to add milestones targets columns to study_plans table

ALTER TABLE study_plans 
ADD COLUMN target_syllabus_completion_date DATE NULL,
ADD COLUMN target_pyq_completion_date DATE NULL,
ADD COLUMN revision_buffer_days INT DEFAULT 14,
ADD COLUMN learn_pct INT DEFAULT 50,
ADD COLUMN practice_pct INT DEFAULT 30,
ADD COLUMN revision_pct INT DEFAULT 20;
