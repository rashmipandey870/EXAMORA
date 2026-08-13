USE examora;

-- 1. Convert JSON array options into a letter-keyed JSON object
UPDATE pyq_questions
SET options_json = JSON_OBJECT(
    'A', JSON_UNQUOTE(JSON_EXTRACT(options_json, '$[0]')),
    'B', JSON_UNQUOTE(JSON_EXTRACT(options_json, '$[1]')),
    'C', JSON_UNQUOTE(JSON_EXTRACT(options_json, '$[2]')),
    'D', JSON_UNQUOTE(JSON_EXTRACT(options_json, '$[3]'))
)
WHERE options_json LIKE '[%';

-- 2. Convert correct_answer text to the matching option letter
UPDATE pyq_questions
SET correct_answer = CASE
    WHEN TRIM(correct_answer) = JSON_UNQUOTE(JSON_EXTRACT(options_json, '$.A')) THEN 'A'
    WHEN TRIM(correct_answer) = JSON_UNQUOTE(JSON_EXTRACT(options_json, '$.B')) THEN 'B'
    WHEN TRIM(correct_answer) = JSON_UNQUOTE(JSON_EXTRACT(options_json, '$.C')) THEN 'C'
    WHEN TRIM(correct_answer) = JSON_UNQUOTE(JSON_EXTRACT(options_json, '$.D')) THEN 'D'
    ELSE correct_answer
END
WHERE LENGTH(correct_answer) > 1;
