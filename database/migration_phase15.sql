USE examora;

SET @gate_id = (SELECT id FROM exams WHERE name = 'GATE CSE' LIMIT 1);
SET @cat_id = (SELECT id FROM exams WHERE name = 'CAT' LIMIT 1);

-- Seed detailed deadline events
INSERT INTO deadline_events (exam_id, event_type, event_date, is_estimated, source) VALUES
(@gate_id, 'APPLICATION_OPEN', '2026-08-01', FALSE, 'Official IITG Notification'),
(@gate_id, 'APPLICATION_CLOSE', '2026-08-22', FALSE, 'Official IITG Notification'), -- 11 days from 2026-08-11!
(@gate_id, 'ADMIT_CARD_RELEASE', '2027-01-03', FALSE, 'Official IITG Notification'),
(@gate_id, 'EXAM_DATE', '2027-02-10', FALSE, 'Official IITG Notification'),

(@cat_id, 'APPLICATION_OPEN', '2027-08-05', TRUE, 'Estimated Trend Analysis'),
(@cat_id, 'APPLICATION_CLOSE', '2027-09-15', TRUE, 'Estimated Trend Analysis'),
(@cat_id, 'EXAM_DATE', '2027-11-28', TRUE, 'Estimated Trend Analysis');
