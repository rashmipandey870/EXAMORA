USE examora;

-- 1. Insert Initial System Exams
INSERT INTO exams (name, exam_year, exam_date, is_custom) VALUES
('GATE CSE', 2027, '2027-02-10', FALSE),
('JEE Main', 2027, '2027-04-15', FALSE),
('UPSC CSE', 2027, '2027-05-30', FALSE),
('CAT', 2027, '2027-11-28', FALSE),
('University Exam', 2027, '2027-06-15', FALSE);

-- Retrieve the ID of the GATE CSE 2027 Exam (assumed to be 1, but we can use variables to be safe)
SET @gate_id = (SELECT id FROM exams WHERE name = 'GATE CSE' LIMIT 1);

-- 2. Insert Syllabus Record
INSERT INTO syllabus (exam_id, version, source_url, source_title, verification_status) VALUES
(@gate_id, '2027.1', 'https://gate.iitg.ac.in/syllabus', 'Official GATE 2027 Computer Science Syllabus', 'VERIFIED');

-- 3. Insert Subjects for GATE CSE
INSERT INTO subjects (exam_id, name) VALUES
(@gate_id, 'Database Management Systems (DBMS)'),
(@gate_id, 'Operating Systems'),
(@gate_id, 'Computer Networks'),
(@gate_id, 'Data Structures & Algorithms'),
(@gate_id, 'Theory of Computation');

SET @dbms_id = (SELECT id FROM subjects WHERE name = 'Database Management Systems (DBMS)' AND exam_id = @gate_id LIMIT 1);
SET @os_id = (SELECT id FROM subjects WHERE name = 'Operating Systems' AND exam_id = @gate_id LIMIT 1);
SET @cn_id = (SELECT id FROM subjects WHERE name = 'Computer Networks' AND exam_id = @gate_id LIMIT 1);
SET @dsa_id = (SELECT id FROM subjects WHERE name = 'Data Structures & Algorithms' AND exam_id = @gate_id LIMIT 1);

-- 4. Insert Topics for Subjects
-- DBMS Topics
INSERT INTO topics (subject_id, name, description, difficulty, importance, frequency, estimated_hours) VALUES
(@dbms_id, 'Transactions & Concurrency Control', 'ACID properties, serializability, locking protocols, 2PL, and deadlocks in databases.', 'HARD', 'HIGH', 'HIGH', 5),
(@dbms_id, 'Normalization', '1NF, 2NF, 3NF, BCNF, dependency preservation, and lossless decomposition.', 'MEDIUM', 'HIGH', 'HIGH', 4),
(@dbms_id, 'Relational Algebra & SQL', 'Queries, relational algebra operators, tuple relational calculus, and SQL commands.', 'MEDIUM', 'HIGH', 'HIGH', 3);

-- OS Topics
INSERT INTO topics (subject_id, name, description, difficulty, importance, frequency, estimated_hours) VALUES
(@os_id, 'CPU Scheduling', 'Scheduling algorithms (FCFS, SJF, Round Robin, Priority) and evaluation.', 'EASY', 'HIGH', 'HIGH', 3),
(@os_id, 'Deadlocks', 'Prevention, avoidance (Banker\'s algorithm), detection, and recovery.', 'MEDIUM', 'HIGH', 'MEDIUM', 3);

-- CN Topics
INSERT INTO topics (subject_id, name, description, difficulty, importance, frequency, estimated_hours) VALUES
(@cn_id, 'IP Addressing & Subnetting', 'IPv4, IPv6, CIDR notation, subnet masks, and routing protocols.', 'HARD', 'HIGH', 'HIGH', 4),
(@cn_id, 'TCP & UDP', 'Connection-oriented vs connectionless protocols, flow control, congestion control.', 'MEDIUM', 'HIGH', 'HIGH', 3);

-- DSA Topics
INSERT INTO topics (subject_id, name, description, difficulty, importance, frequency, estimated_hours) VALUES
(@dsa_id, 'Binary Trees & Traversals', 'BST, tree traversals (inorder, preorder, postorder), and AVL trees.', 'MEDIUM', 'HIGH', 'HIGH', 4),
(@dsa_id, 'Graph Algorithms', 'BFS, DFS, Dijkstra\'s algorithm, Prim\'s and Kruskal\'s MST algorithms.', 'HARD', 'HIGH', 'HIGH', 5);

-- 5. Insert Source Provenance Reference
INSERT INTO sources (exam_id, url, title, source_type, verification_status) VALUES
(@gate_id, 'https://gate.iitg.ac.in/syllabus', 'Official GATE 2027 Syllabus PDF', 'SYLLABUS', 'VERIFIED');
