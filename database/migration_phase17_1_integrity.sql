USE examora;

-- 1. Add last_checked_at column to deadline_events
-- ALTER TABLE deadline_events ADD COLUMN last_checked_at TIMESTAMP NULL DEFAULT NULL;

-- 2. Clear and re-seed deadline_events with data honesty constraints
DELETE FROM deadline_events;

SET @gate_id = (SELECT id FROM exams WHERE name = 'GATE CSE' LIMIT 1);
SET @cat_id = (SELECT id FROM exams WHERE name = 'CAT' LIMIT 1);

INSERT INTO deadline_events (exam_id, event_type, event_date, is_estimated, source, last_checked_at) VALUES
(@gate_id, 'APPLICATION_OPEN', '2026-08-14', FALSE, 'https://gate2027.iitm.ac.in', CURRENT_TIMESTAMP),
(@gate_id, 'APPLICATION_CLOSE', '2026-09-21', FALSE, 'https://gate2027.iitm.ac.in', CURRENT_TIMESTAMP),
(@gate_id, 'ADMIT_CARD_RELEASE', '2027-01-08', TRUE, 'https://gate2027.iitm.ac.in', CURRENT_TIMESTAMP),
(@gate_id, 'EXAM_DATE', '2027-02-06', FALSE, 'https://gate2027.iitm.ac.in', CURRENT_TIMESTAMP),

(@cat_id, 'APPLICATION_OPEN', '2027-08-05', TRUE, 'https://iimcat.ac.in', CURRENT_TIMESTAMP),
(@cat_id, 'APPLICATION_CLOSE', '2027-09-15', TRUE, 'https://iimcat.ac.in', CURRENT_TIMESTAMP),
(@cat_id, 'EXAM_DATE', '2027-11-28', TRUE, 'https://iimcat.ac.in', CURRENT_TIMESTAMP);


-- 3. Clear and re-seed pyq_questions (marked as AI practice questions)
DELETE FROM pyq_questions;

SET @dbms_id = (SELECT id FROM subjects WHERE name LIKE 'Database Management Systems%' LIMIT 1);
SET @sql_topic_id = (SELECT id FROM topics WHERE name = 'Relational Algebra & SQL' LIMIT 1);
SET @norm_topic_id = (SELECT id FROM topics WHERE name = 'Normalization' LIMIT 1);
SET @tcc_topic_id = (SELECT id FROM topics WHERE name = 'Transactions & Concurrency Control' LIMIT 1);

INSERT INTO pyq_questions (exam_id, subject_id, topic_id, year, question_text, options_json, correct_answer, explanation, difficulty, marks, is_verified, source) VALUES
-- Relational Algebra & SQL
(@gate_id, @dbms_id, @sql_topic_id, 2024, 'Given a relational schema R(A, B, C, D) and SQL query: SELECT A, SUM(B) FROM R GROUP BY A HAVING SUM(B) > 10. What is the execution order of clauses?', '["FROM, GROUP BY, HAVING, SELECT", "FROM, SELECT, GROUP BY, HAVING", "SELECT, FROM, GROUP BY, HAVING", "FROM, HAVING, GROUP BY, SELECT"]', 'FROM, GROUP BY, HAVING, SELECT', 'The logical query processing phase order is: FROM first, then WHERE (if any), then GROUP BY, then HAVING, then SELECT, and finally ORDER BY.', 'MEDIUM', 1.00, FALSE, 'AI-generated, exam-style practice'),
(@gate_id, @dbms_id, @sql_topic_id, 2023, 'Which of the following relational algebra expressions yields the set difference of relations R and S?', '["R - S", "R Intersection S", "R Union S", "R Cartesian Product S"]', 'R - S', 'Set difference operation returns tuples present in R but not in S. Represented as R - S.', 'EASY', 1.00, FALSE, 'AI-generated, exam-style practice'),
(@gate_id, @dbms_id, @sql_topic_id, 2021, 'Which relational algebra operation is equivalent to a Cartesian product followed by a selection?', '["Theta Join", "Natural Join", "Outer Join", "Project"]', 'Theta Join', 'Theta join is defined as a selection operation performed on the Cartesian product of two relations.', 'MEDIUM', 1.00, FALSE, 'AI-generated, exam-style practice'),
(@gate_id, @dbms_id, @sql_topic_id, 2020, 'Which SQL keyword is used to eliminate duplicate rows from the query results?', '["DISTINCT", "UNIQUE", "GROUP BY", "ORDER BY"]', 'DISTINCT', 'The DISTINCT keyword is placed immediately after SELECT to filter out duplicate output rows.', 'EASY', 1.00, FALSE, 'AI-generated, exam-style practice'),

-- Normalization
(@gate_id, @dbms_id, @norm_topic_id, 2022, 'Consider relation R(A, B, C, D, E) with FDs: A->B, BC->D, E->A. What is the primary candidate key of R?', '["{E, C}", "{A, C}", "{B, C}", "{C, D}"]', '{E, C}', 'Calculating attribute closure: {E,C}+ = {E,C,A,B,D}. Since it contains all attributes of the relation, {E,C} is the minimal candidate key.', 'MEDIUM', 2.00, FALSE, 'AI-generated, exam-style practice'),
(@gate_id, @dbms_id, @norm_topic_id, 2021, 'If a relation R is in Boyce-Codd Normal Form (BCNF), which of the following is true for every non-trivial FD X->Y?', '["X is a superkey of R", "Y is a prime attribute", "X is a primary key subset", "R must only have two attributes"]', 'X is a superkey of R', 'By definition, BCNF requires that for every non-trivial dependency X->Y, the determinant X must be a superkey.', 'MEDIUM', 1.00, FALSE, 'AI-generated, exam-style practice'),
(@gate_id, @dbms_id, @norm_topic_id, 2019, 'What is the highest normal form satisfied by a relation with only prime attributes?', '["3NF", "2NF", "BCNF", "1NF"]', '3NF', 'If all attributes are prime, there can be no transitive dependencies of non-prime attributes on candidate keys, so it satisfies 3NF. But it might violate BCNF.', 'HARD', 2.00, FALSE, 'AI-generated, exam-style practice'),
(@gate_id, @dbms_id, @norm_topic_id, 2018, 'A relation R(A, B, C) has functional dependency A->B. If candidate keys are {A} and {C}, which normal form is R in?', '["3NF", "BCNF", "2NF", "1NF"]', '3NF', 'A is a candidate key (superkey), so A->B does not violate 3NF. Thus the relation is in 3NF.', 'HARD', 2.00, FALSE, 'AI-generated, exam-style practice'),

-- Transactions & Concurrency Control
(@gate_id, @dbms_id, @tcc_topic_id, 2025, 'Under the Wait-Die deadlock prevention scheme, what happens if an older transaction T_old requests a lock held by a younger transaction T_young?', '["T_old waits for T_young to release the lock", "T_old dies immediately", "T_young is aborted (killed)", "Both transactions enter deadlock rollback"]', 'T_old waits for T_young to release the lock', 'In Wait-Die, older transactions are allowed to wait for younger ones (Old waits, Young dies). Therefore, T_old waits.', 'HARD', 2.00, FALSE, 'AI-generated, exam-style practice'),
(@gate_id, @dbms_id, @tcc_topic_id, 2024, 'Which property of database transactions ensures that either all operations of the transaction are reflected in the database or none are?', '["Atomicity", "Consistency", "Isolation", "Durability"]', 'Atomicity', 'Atomicity is the "all-or-nothing" property that ensures complete transactional updates or rollbacks.', 'EASY', 1.00, FALSE, 'AI-generated, exam-style practice'),
(@gate_id, @dbms_id, @tcc_topic_id, 2023, 'Which lock type allows multiple transactions to read a database item simultaneously but prevents any write operations?', '["Shared Lock (S)", "Exclusive Lock (X)", "Intention Shared Lock (IS)", "Intention Exclusive Lock (IX)"]', 'Shared Lock (S)', 'Shared locks are read-only locks that can be held concurrently by multiple transactions.', 'EASY', 1.00, FALSE, 'AI-generated, exam-style practice'),
(@gate_id, @dbms_id, @tcc_topic_id, 2022, 'Under the Wound-Wait deadlock prevention scheme, what happens if an older transaction T_old requests a lock held by a younger transaction T_young?', '["T_old wounds (aborts) T_young", "T_old waits for T_young to release the lock", "T_old dies immediately", "T_young waits for T_old to release the lock"]', 'T_old wounds (aborts) T_young', 'In Wound-Wait, older transactions wound (abort/kill) younger transactions holding requested locks. Therefore, T_old wounds T_young.', 'HARD', 2.00, FALSE, 'AI-generated, exam-style practice');
