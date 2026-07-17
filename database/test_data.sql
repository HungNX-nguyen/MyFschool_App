/* =========================================================
   MyFschool - Confirmed test data
   Run manually after database/script.sql.
   Password for every login account: Test@123456

   COMPLETE LOGIN ACCOUNT LIST BY ROLE

   ADMIN - login by username:
   - admin_test01
   - admin_test02

   TEACHER - login by phone:
   - 0919000001 (teacher_test01)
   - 0919000002 (teacher_test02)
   - 0909000001 (parent_teacher_test01, multi-role)
   - 0929000001 (subject_teacher01 - Ngữ văn)
   - 0929000002 (subject_teacher02 - Toán)
   - 0929000003 (subject_teacher03 - Tiếng Anh)
   - 0929000004 (subject_teacher04 - Lịch sử)
   - 0929000005 (subject_teacher05 - Địa lý)
   - 0929000006 (subject_teacher06 - Vật lý)
   - 0929000007 (subject_teacher07 - Hóa học)
   - 0929000008 (subject_teacher08 - Sinh học)
   - 0929000009 (subject_teacher09 - Tin học)
   - 0929000010 (subject_teacher10 - Công nghệ)
   - 0929000011 (subject_teacher11 - Giáo dục thể chất)
   - 0929000012 (subject_teacher12 - Giáo dục quốc phòng và an ninh)
   - 0929000013 (subject_teacher13 - Giáo dục công dân)

   PARENT - login by phone:
   - 0989000001 (parent_test01)
   - 0989000002 (parent_test02)
   - 0989100001 (parent_seed01)
   - 0989100002 (parent_seed02)
   - 0989100003 (parent_seed03)
   - 0989100004 (parent_seed04)
   - 0989100005 (parent_seed05)
   - 0989100006 (parent_seed06)
   - 0989100007 (parent_seed07)
   - 0989100008 (parent_seed08)
   - 0989100009 (parent_seed09)
   - 0989100010 (parent_seed10)
   - 0909000001 (parent_teacher_test01, multi-role)

   STUDENT - login by username:
   - student_test01 (10A1)
   - student_test02 (11A1)
   - student_test03 (12A1)
   - student_test04 (10A1)

   MULTI-ROLE PARENT + TEACHER - login by phone:
   - 0909000001 (parent_teacher_test01)

   Business seed summary:
   - 3 Teacher profiles are homeroom teachers of 10A1, 11A1, 12A1.
   - Homeroom Teachers also teach one main subject in their own class:
     teacher_test01 teaches Toán in 10A1, teacher_test02 teaches Ngữ văn
     in 11A1, and parent_teacher_test01 teaches Tiếng Anh in 12A1.
   - 4 Student login accounts are assigned to 10A1, 11A1, 12A1.
   - 30 additional Student profiles are split evenly: 10 per class.
   - The 30 additional Students do not have login accounts.
   - 10 additional Parent login accounts and the multi-role Parent
     receive linked students.
   - 13 subject Teacher accounts cover 13 subjects; GDCD is elective for 12A1 only.
   - Historical class structure is available for learning results in 2024-2025 and 2025-2026.
   - Historical learning data contains 2 DDG_TX, 1 DDG_GK and 1 DDG_CK per subject/semester.
   - Historical closed years contain 1,287 finalized learning_result snapshots rebuilt from grade.
   - The active year 2026-2027 intentionally has no finalized learning_result snapshot.
   - 10 School Event records cover visible and hidden SCHOOL/CLASS test cases.
   - HK1 timetables follow the confirmed morning/afternoon lesson slots.
   - "Chào cờ" and "Sinh hoạt lớp" are UI-only fixed periods, not Subjects.
   ========================================================= */

USE myfschool;

START TRANSACTION;

INSERT INTO account (
  username,
  email,
  phone,
  password_hash,
  status,
  last_login_at
) VALUES
  (
    'admin_test01',
    'admin_test01@myfschool.test',
    NULL,
    '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W',
    'ACTIVE',
    NULL
  ),
  (
    'admin_test02',
    'admin_test02@myfschool.test',
    NULL,
    '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W',
    'ACTIVE',
    NULL
  ),
  (
    'teacher_test01',
    'teacher_test01@myfschool.test',
    '0919000001',
    '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W',
    'ACTIVE',
    NULL
  ),
  (
    'teacher_test02',
    'teacher_test02@myfschool.test',
    '0919000002',
    '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W',
    'ACTIVE',
    NULL
  ),
  (
    'parent_test01',
    'parent_test01@myfschool.test',
    '0989000001',
    '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W',
    'ACTIVE',
    NULL
  ),
  (
    'parent_test02',
    'parent_test02@myfschool.test',
    '0989000002',
    '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W',
    'ACTIVE',
    NULL
  ),
  (
    'student_test01',
    'student_test01@myfschool.test',
    NULL,
    '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W',
    'ACTIVE',
    NULL
  ),
  (
    'student_test02',
    'student_test02@myfschool.test',
    NULL,
    '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W',
    'ACTIVE',
    NULL
  ),
  (
    'student_test03',
    'student_test03@myfschool.test',
    NULL,
    '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W',
    'ACTIVE',
    NULL
  ),
  (
    'student_test04',
    'student_test04@myfschool.test',
    NULL,
    '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W',
    'ACTIVE',
    NULL
  )
ON DUPLICATE KEY UPDATE
  email = VALUES(email),
  phone = VALUES(phone),
  password_hash = VALUES(password_hash),
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO account_role (account_id, role, status)
SELECT id, 'ADMIN', 'ACTIVE'
FROM account
WHERE username IN ('admin_test01', 'admin_test02')
UNION ALL
SELECT id, 'TEACHER', 'ACTIVE'
FROM account
WHERE username IN ('teacher_test01', 'teacher_test02')
UNION ALL
SELECT id, 'PARENT', 'ACTIVE'
FROM account
WHERE username IN ('parent_test01', 'parent_test02')
UNION ALL
SELECT id, 'STUDENT', 'ACTIVE'
FROM account
WHERE username IN (
  'student_test01',
  'student_test02',
  'student_test03',
  'student_test04'
)
ON DUPLICATE KEY UPDATE
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO account (
  username,
  email,
  phone,
  password_hash,
  status,
  last_login_at
) VALUES (
  'parent_teacher_test01',
  'parent_teacher_test01@myfschool.test',
  '0909000001',
  '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W',
  'ACTIVE',
  NULL
)
ON DUPLICATE KEY UPDATE
  email = VALUES(email),
  phone = VALUES(phone),
  password_hash = VALUES(password_hash),
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO account_role (account_id, role, status)
SELECT id, 'PARENT', 'ACTIVE'
FROM account
WHERE username = 'parent_teacher_test01'
UNION ALL
SELECT id, 'TEACHER', 'ACTIVE'
FROM account
WHERE username = 'parent_teacher_test01'
ON DUPLICATE KEY UPDATE
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO parent (
  account_id,
  full_name,
  phone,
  email,
  status
)
SELECT
  id,
  'Phụ huynh Test 01',
  phone,
  email,
  'ACTIVE'
FROM account
WHERE username = 'parent_test01'
UNION ALL
SELECT
  id,
  'Phụ huynh Test 02',
  phone,
  email,
  'ACTIVE'
FROM account
WHERE username = 'parent_test02'
ON DUPLICATE KEY UPDATE
  full_name = VALUES(full_name),
  phone = VALUES(phone),
  email = VALUES(email),
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO student (
  account_id,
  student_code,
  full_name,
  date_of_birth,
  gender,
  current_class_id,
  status
)
SELECT
  id,
  'STU_TEST_001',
  'Học sinh Test 01',
  '2012-01-15',
  'MALE',
  NULL,
  'PENDING_CLASS_ASSIGNMENT'
FROM account
WHERE username = 'student_test01'
UNION ALL
SELECT
  id,
  'STU_TEST_002',
  'Học sinh Test 02',
  '2012-04-20',
  'FEMALE',
  NULL,
  'PENDING_CLASS_ASSIGNMENT'
FROM account
WHERE username = 'student_test02'
UNION ALL
SELECT
  id,
  'STU_TEST_003',
  'Học sinh Test 03',
  '2013-02-10',
  'MALE',
  NULL,
  'PENDING_CLASS_ASSIGNMENT'
FROM account
WHERE username = 'student_test03'
UNION ALL
SELECT
  id,
  'STU_TEST_004',
  'Học sinh Test 04',
  '2013-09-05',
  'FEMALE',
  NULL,
  'PENDING_CLASS_ASSIGNMENT'
FROM account
WHERE username = 'student_test04'
ON DUPLICATE KEY UPDATE
  student_code = VALUES(student_code),
  full_name = VALUES(full_name),
  date_of_birth = VALUES(date_of_birth),
  gender = VALUES(gender),
  current_class_id = NULL,
  status = 'PENDING_CLASS_ASSIGNMENT',
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO parent_student (
  parent_id,
  student_id,
  relationship,
  is_primary_contact,
  status
)
SELECT
  p.id,
  s.id,
  'PARENT',
  1,
  'ACTIVE'
FROM parent p
JOIN account pa ON pa.id = p.account_id
JOIN student s ON s.student_code = 'STU_TEST_001'
WHERE pa.username = 'parent_test01'
UNION ALL
SELECT
  p.id,
  s.id,
  'PARENT',
  1,
  'ACTIVE'
FROM parent p
JOIN account pa ON pa.id = p.account_id
JOIN student s ON s.student_code = 'STU_TEST_003'
WHERE pa.username = 'parent_test01'
UNION ALL
SELECT
  p.id,
  s.id,
  'PARENT',
  1,
  'ACTIVE'
FROM parent p
JOIN account pa ON pa.id = p.account_id
JOIN student s ON s.student_code = 'STU_TEST_002'
WHERE pa.username = 'parent_test02'
UNION ALL
SELECT
  p.id,
  s.id,
  'PARENT',
  1,
  'ACTIVE'
FROM parent p
JOIN account pa ON pa.id = p.account_id
JOIN student s ON s.student_code = 'STU_TEST_004'
WHERE pa.username = 'parent_test02'
ON DUPLICATE KEY UPDATE
  relationship = VALUES(relationship),
  is_primary_contact = VALUES(is_primary_contact),
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

/* =========================================================
   Additional Parent login accounts
   ========================================================= */

INSERT INTO account (
  username,
  email,
  phone,
  password_hash,
  status,
  last_login_at
) VALUES
  ('parent_seed01', 'parent_seed01@myfschool.test', '0989100001', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('parent_seed02', 'parent_seed02@myfschool.test', '0989100002', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('parent_seed03', 'parent_seed03@myfschool.test', '0989100003', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('parent_seed04', 'parent_seed04@myfschool.test', '0989100004', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('parent_seed05', 'parent_seed05@myfschool.test', '0989100005', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('parent_seed06', 'parent_seed06@myfschool.test', '0989100006', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('parent_seed07', 'parent_seed07@myfschool.test', '0989100007', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('parent_seed08', 'parent_seed08@myfschool.test', '0989100008', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('parent_seed09', 'parent_seed09@myfschool.test', '0989100009', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('parent_seed10', 'parent_seed10@myfschool.test', '0989100010', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL)
ON DUPLICATE KEY UPDATE
  email = VALUES(email),
  phone = VALUES(phone),
  password_hash = VALUES(password_hash),
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO account_role (account_id, role, status)
SELECT id, 'PARENT', 'ACTIVE'
FROM account
WHERE username IN (
  'parent_seed01',
  'parent_seed02',
  'parent_seed03',
  'parent_seed04',
  'parent_seed05',
  'parent_seed06',
  'parent_seed07',
  'parent_seed08',
  'parent_seed09',
  'parent_seed10'
)
ON DUPLICATE KEY UPDATE
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

/* Create Parent profiles for the 10 new accounts and the multi-role account. */
INSERT INTO parent (
  account_id,
  full_name,
  phone,
  email,
  status
)
SELECT
  a.id,
  CASE
    WHEN a.username = 'parent_teacher_test01'
      THEN 'Phụ huynh/Giáo viên Test 01'
    ELSE CONCAT('Phụ huynh Seed ', RIGHT(a.username, 2))
  END,
  a.phone,
  a.email,
  'ACTIVE'
FROM account a
WHERE a.username = 'parent_teacher_test01'
   OR a.username LIKE 'parent_seed__'
ON DUPLICATE KEY UPDATE
  full_name = VALUES(full_name),
  phone = VALUES(phone),
  email = VALUES(email),
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

/* =========================================================
   Teacher profiles and academic structure
   ========================================================= */

INSERT INTO teacher (
  account_id,
  teacher_code,
  full_name,
  phone,
  email,
  status
)
SELECT
  a.id,
  CASE a.username
    WHEN 'teacher_test01' THEN 'TCH_TEST_001'
    WHEN 'teacher_test02' THEN 'TCH_TEST_002'
    ELSE 'TCH_TEST_003'
  END,
  CASE a.username
    WHEN 'teacher_test01' THEN 'Giáo viên Test 01'
    WHEN 'teacher_test02' THEN 'Giáo viên Test 02'
    ELSE 'Giáo viên/Phụ huynh Test 01'
  END,
  a.phone,
  a.email,
  'ACTIVE'
FROM account a
WHERE a.username IN (
  'teacher_test01',
  'teacher_test02',
  'parent_teacher_test01'
)
ON DUPLICATE KEY UPDATE
  teacher_code = VALUES(teacher_code),
  full_name = VALUES(full_name),
  phone = VALUES(phone),
  email = VALUES(email),
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO academic_year (
  name,
  start_date,
  end_date,
  status
) VALUES
  ('2024-2025', '2024-08-01', '2025-05-31', 'CLOSED'),
  ('2025-2026', '2025-08-01', '2026-05-31', 'CLOSED'),
  ('2026-2027', '2026-08-01', '2027-05-31', 'ACTIVE')
ON DUPLICATE KEY UPDATE
  start_date = VALUES(start_date),
  end_date = VALUES(end_date),
  status = VALUES(status),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO grade_level (name, level_number, description) VALUES
  ('Khối 10', 10, 'Khối 10 - test data'),
  ('Khối 11', 11, 'Khối 11 - test data'),
  ('Khối 12', 12, 'Khối 12 - test data')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  description = VALUES(description);

INSERT INTO class (
  academic_year_id,
  grade_level_id,
  homeroom_teacher_id,
  class_code,
  class_name,
  status
)
SELECT
  ay.id,
  gl.id,
  t.id,
  mapping.class_code,
  mapping.class_name,
  'ACTIVE'
FROM (
  SELECT 10 AS level_number, 'teacher_test01' AS teacher_username,
         '10A1' AS class_code, '10A1' AS class_name
  UNION ALL
  SELECT 11, 'teacher_test02', '11A1', '11A1'
  UNION ALL
  SELECT 12, 'parent_teacher_test01', '12A1', '12A1'
) mapping
JOIN academic_year ay ON ay.name = '2026-2027'
JOIN grade_level gl ON gl.level_number = mapping.level_number
JOIN account a ON a.username = mapping.teacher_username
JOIN teacher t ON t.account_id = a.id
ON DUPLICATE KEY UPDATE
  grade_level_id = VALUES(grade_level_id),
  homeroom_teacher_id = VALUES(homeroom_teacher_id),
  class_name = VALUES(class_name),
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

/* Historical classes required by learning-result snapshots. */
INSERT INTO class (
  academic_year_id,
  grade_level_id,
  homeroom_teacher_id,
  class_code,
  class_name,
  status
)
SELECT
  ay.id,
  gl.id,
  NULL,
  mapping.class_code,
  mapping.class_name,
  'CLOSED'
FROM (
  SELECT '2024-2025' AS academic_year_name, 10 AS level_number,
         '10A1' AS class_code, '10A1' AS class_name
  UNION ALL SELECT '2025-2026', 10, '10A1', '10A1'
  UNION ALL SELECT '2025-2026', 11, '11A1', '11A1'
) mapping
JOIN academic_year ay ON ay.name = mapping.academic_year_name
JOIN grade_level gl ON gl.level_number = mapping.level_number
ON DUPLICATE KEY UPDATE
  grade_level_id = VALUES(grade_level_id),
  class_name = VALUES(class_name),
  status = 'CLOSED',
  updated_at = CURRENT_TIMESTAMP;

/* Assign the four Student login accounts after their classes exist. */
UPDATE student s
JOIN account a ON a.id = s.account_id
JOIN (
  SELECT 'student_test01' AS username, '10A1' AS class_code
  UNION ALL SELECT 'student_test02', '11A1'
  UNION ALL SELECT 'student_test03', '12A1'
  UNION ALL SELECT 'student_test04', '10A1'
) mapping ON mapping.username = a.username
JOIN academic_year ay ON ay.name = '2026-2027'
JOIN class c
  ON c.academic_year_id = ay.id
 AND c.class_code = mapping.class_code
SET
  s.current_class_id = c.id,
  s.status = 'ACTIVE',
  s.updated_at = CURRENT_TIMESTAMP;

/* =========================================================
   30 Students: 10 per class, without login accounts
   ========================================================= */

INSERT INTO student (
  account_id,
  student_code,
  full_name,
  date_of_birth,
  gender,
  current_class_id,
  status
)
SELECT
  NULL,
  CONCAT('STU_SEED_', LPAD(seed.seed_number, 3, '0')),
  CONCAT('Học sinh Seed ', LPAD(seed.seed_number, 2, '0')),
  DATE_ADD(
    MAKEDATE(2011 - seed.class_index, 1),
    INTERVAL seed.student_number * 7 DAY
  ),
  IF(MOD(seed.seed_number, 2) = 0, 'FEMALE', 'MALE'),
  c.id,
  'ACTIVE'
FROM (
  SELECT
    class_group.class_index,
    student_number.student_number,
    class_group.class_index * 10 + student_number.student_number AS seed_number,
    CASE class_group.class_index
      WHEN 0 THEN '10A1'
      WHEN 1 THEN '11A1'
      ELSE '12A1'
    END AS class_code
  FROM (
    SELECT 0 AS class_index
    UNION ALL SELECT 1
    UNION ALL SELECT 2
  ) class_group
  CROSS JOIN (
    SELECT 1 AS student_number
    UNION ALL SELECT 2
    UNION ALL SELECT 3
    UNION ALL SELECT 4
    UNION ALL SELECT 5
    UNION ALL SELECT 6
    UNION ALL SELECT 7
    UNION ALL SELECT 8
    UNION ALL SELECT 9
    UNION ALL SELECT 10
  ) student_number
) seed
JOIN academic_year ay ON ay.name = '2026-2027'
JOIN class c
  ON c.academic_year_id = ay.id
 AND c.class_code = seed.class_code
ON DUPLICATE KEY UPDATE
  full_name = VALUES(full_name),
  date_of_birth = VALUES(date_of_birth),
  gender = VALUES(gender),
  current_class_id = VALUES(current_class_id),
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO student_class_history (
  student_id,
  class_id,
  academic_year_id,
  start_date,
  end_date,
  status,
  note
)
SELECT
  s.id,
  s.current_class_id,
  ay.id,
  ay.start_date,
  NULL,
  'ACTIVE',
  'Initial class assignment from test_data.sql'
FROM student s
JOIN academic_year ay ON ay.name = '2026-2027'
WHERE (
    s.student_code LIKE 'STU_SEED_%'
    OR s.student_code LIKE 'STU_TEST_%'
  )
  AND s.current_class_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM student_class_history history
    WHERE history.student_id = s.id
      AND history.class_id = s.current_class_id
      AND history.academic_year_id = ay.id
      AND history.status = 'ACTIVE'
  );

/*
  Historical progression:
  - Current 11A1 students studied in 10A1 during 2025-2026.
  - Current 12A1 students studied in 10A1 during 2024-2025 and 11A1 during 2025-2026.
  - Current 10A1 students have no previous high-school learning results.
*/
INSERT INTO student_class_history (
  student_id,
  class_id,
  academic_year_id,
  start_date,
  end_date,
  status,
  note
)
SELECT
  s.id,
  historical_class.id,
  historical_year.id,
  historical_year.start_date,
  historical_year.end_date,
  'COMPLETED',
  CONCAT('Historical class progression for ', mapping.academic_year_name)
FROM student s
JOIN class current_class ON current_class.id = s.current_class_id
JOIN academic_year current_year
  ON current_year.id = current_class.academic_year_id
 AND current_year.name = '2026-2027'
JOIN (
  SELECT '11A1' AS current_class_code, '2025-2026' AS academic_year_name, '10A1' AS historical_class_code
  UNION ALL SELECT '12A1', '2024-2025', '10A1'
  UNION ALL SELECT '12A1', '2025-2026', '11A1'
) mapping ON mapping.current_class_code = current_class.class_code
JOIN academic_year historical_year ON historical_year.name = mapping.academic_year_name
JOIN class historical_class
  ON historical_class.academic_year_id = historical_year.id
 AND historical_class.class_code = mapping.historical_class_code
WHERE NOT EXISTS (
  SELECT 1
  FROM student_class_history history
  WHERE history.student_id = s.id
    AND history.class_id = historical_class.id
    AND history.academic_year_id = historical_year.id
);

/* Multi-role Parent gets 1 child; seed Parent 01 gets 2;
   seed Parent 02-10 get 3 children each. */
INSERT INTO parent_student (
  parent_id,
  student_id,
  relationship,
  is_primary_contact,
  status
)
SELECT
  p.id,
  mapped.student_id,
  'PARENT',
  1,
  'ACTIVE'
FROM (
  SELECT
    s.id AS student_id,
    CAST(RIGHT(s.student_code, 3) AS UNSIGNED) AS seed_number,
    CASE
      WHEN CAST(RIGHT(s.student_code, 3) AS UNSIGNED) = 1
        THEN 'parent_teacher_test01'
      WHEN CAST(RIGHT(s.student_code, 3) AS UNSIGNED) BETWEEN 2 AND 3
        THEN 'parent_seed01'
      ELSE CONCAT(
        'parent_seed',
        LPAD(
          FLOOR((CAST(RIGHT(s.student_code, 3) AS UNSIGNED) - 4) / 3) + 2,
          2,
          '0'
        )
      )
    END AS parent_username
  FROM student s
  WHERE s.student_code LIKE 'STU_SEED_%'
) mapped
JOIN account a ON a.username = mapped.parent_username
JOIN parent p ON p.account_id = a.id
ON DUPLICATE KEY UPDATE
  relationship = VALUES(relationship),
  is_primary_contact = VALUES(is_primary_contact),
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

/* =========================================================
   Subject teachers, subjects, assignments and timetable seed
   ========================================================= */

/* 13 subject-teacher login accounts. All use password Test@123456. */
INSERT INTO account (
  username,
  email,
  phone,
  password_hash,
  status,
  last_login_at
) VALUES
  ('subject_teacher01', 'subject_teacher01@myfschool.test', '0929000001', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('subject_teacher02', 'subject_teacher02@myfschool.test', '0929000002', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('subject_teacher03', 'subject_teacher03@myfschool.test', '0929000003', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('subject_teacher04', 'subject_teacher04@myfschool.test', '0929000004', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('subject_teacher05', 'subject_teacher05@myfschool.test', '0929000005', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('subject_teacher06', 'subject_teacher06@myfschool.test', '0929000006', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('subject_teacher07', 'subject_teacher07@myfschool.test', '0929000007', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('subject_teacher08', 'subject_teacher08@myfschool.test', '0929000008', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('subject_teacher09', 'subject_teacher09@myfschool.test', '0929000009', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('subject_teacher10', 'subject_teacher10@myfschool.test', '0929000010', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('subject_teacher11', 'subject_teacher11@myfschool.test', '0929000011', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('subject_teacher12', 'subject_teacher12@myfschool.test', '0929000012', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL),
  ('subject_teacher13', 'subject_teacher13@myfschool.test', '0929000013', '$2a$10$eoJjzhALzEOEktAXv9yMyu5XKw379Go.rqN5cZyaskqM5gpasuH4W', 'ACTIVE', NULL)
ON DUPLICATE KEY UPDATE
  email = VALUES(email),
  phone = VALUES(phone),
  password_hash = VALUES(password_hash),
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO account_role (account_id, role, status)
SELECT id, 'TEACHER', 'ACTIVE'
FROM account
WHERE username IN (
  'subject_teacher01',
  'subject_teacher02',
  'subject_teacher03',
  'subject_teacher04',
  'subject_teacher05',
  'subject_teacher06',
  'subject_teacher07',
  'subject_teacher08',
  'subject_teacher09',
  'subject_teacher10',
  'subject_teacher11',
  'subject_teacher12',
  'subject_teacher13'
)
ON DUPLICATE KEY UPDATE
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teacher (
  account_id,
  teacher_code,
  full_name,
  phone,
  email,
  status
)
SELECT
  a.id,
  mapping.teacher_code,
  mapping.full_name,
  a.phone,
  a.email,
  'ACTIVE'
FROM (
  SELECT 'subject_teacher01' AS username, 'TCH_SUBJECT_001' AS teacher_code, 'Giáo viên Ngữ văn' AS full_name
  UNION ALL SELECT 'subject_teacher02', 'TCH_SUBJECT_002', 'Giáo viên Toán'
  UNION ALL SELECT 'subject_teacher03', 'TCH_SUBJECT_003', 'Giáo viên Tiếng Anh'
  UNION ALL SELECT 'subject_teacher04', 'TCH_SUBJECT_004', 'Giáo viên Lịch sử'
  UNION ALL SELECT 'subject_teacher05', 'TCH_SUBJECT_005', 'Giáo viên Địa lý'
  UNION ALL SELECT 'subject_teacher06', 'TCH_SUBJECT_006', 'Giáo viên Vật lý'
  UNION ALL SELECT 'subject_teacher07', 'TCH_SUBJECT_007', 'Giáo viên Hóa học'
  UNION ALL SELECT 'subject_teacher08', 'TCH_SUBJECT_008', 'Giáo viên Sinh học'
  UNION ALL SELECT 'subject_teacher09', 'TCH_SUBJECT_009', 'Giáo viên Tin học'
  UNION ALL SELECT 'subject_teacher10', 'TCH_SUBJECT_010', 'Giáo viên Công nghệ'
  UNION ALL SELECT 'subject_teacher11', 'TCH_SUBJECT_011', 'Giáo viên Giáo dục thể chất'
  UNION ALL SELECT 'subject_teacher12', 'TCH_SUBJECT_012', 'Giáo viên Giáo dục quốc phòng và an ninh'
  UNION ALL SELECT 'subject_teacher13', 'TCH_SUBJECT_013', 'Giáo viên Giáo dục công dân'
) mapping
JOIN account a ON a.username = mapping.username
ON DUPLICATE KEY UPDATE
  teacher_code = VALUES(teacher_code),
  full_name = VALUES(full_name),
  phone = VALUES(phone),
  email = VALUES(email),
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

/* Chào cờ and Sinh hoạt lớp are intentionally excluded from subject. */
INSERT INTO subject (subject_code, subject_name, description, status) VALUES
  ('NGU_VAN', 'Ngữ văn', 'Môn Ngữ văn', 'ACTIVE'),
  ('TOAN', 'Toán', 'Môn Toán', 'ACTIVE'),
  ('TIENG_ANH', 'Tiếng Anh', 'Môn Tiếng Anh', 'ACTIVE'),
  ('LICH_SU', 'Lịch sử', 'Môn Lịch sử', 'ACTIVE'),
  ('DIA_LY', 'Địa lý', 'Môn Địa lý', 'ACTIVE'),
  ('VAT_LY', 'Vật lý', 'Môn Vật lý', 'ACTIVE'),
  ('HOA_HOC', 'Hóa học', 'Môn Hóa học', 'ACTIVE'),
  ('SINH_HOC', 'Sinh học', 'Môn Sinh học', 'ACTIVE'),
  ('TIN_HOC', 'Tin học', 'Môn Tin học', 'ACTIVE'),
  ('CONG_NGHE', 'Công nghệ', 'Môn Công nghệ', 'ACTIVE'),
  ('GD_THE_CHAT', 'Giáo dục thể chất', 'Môn Giáo dục thể chất', 'ACTIVE'),
  ('GD_QPAN', 'Giáo dục quốc phòng và an ninh', 'Môn Giáo dục quốc phòng và an ninh', 'ACTIVE'),
  ('GDCD', 'Giáo dục công dân', 'Môn Giáo dục công dân', 'ACTIVE')
ON DUPLICATE KEY UPDATE
  subject_name = VALUES(subject_name),
  description = VALUES(description),
  status = 'ACTIVE';

INSERT INTO semester (
  academic_year_id,
  name,
  semester_index,
  start_date,
  end_date,
  status
)
SELECT
  ay.id,
  mapping.semester_name,
  mapping.semester_index,
  mapping.start_date,
  mapping.end_date,
  mapping.status
FROM (
  SELECT '2024-2025' AS academic_year_name, 'Học kỳ 1' AS semester_name,
         1 AS semester_index, CAST('2024-08-01' AS DATE) AS start_date,
         CAST('2024-12-31' AS DATE) AS end_date, 'CLOSED' AS status
  UNION ALL SELECT '2024-2025', 'Học kỳ 2', 2, '2025-01-01', '2025-05-31', 'CLOSED'
  UNION ALL SELECT '2025-2026', 'Học kỳ 1', 1, '2025-08-01', '2025-12-31', 'CLOSED'
  UNION ALL SELECT '2025-2026', 'Học kỳ 2', 2, '2026-01-01', '2026-05-31', 'CLOSED'
  UNION ALL SELECT '2026-2027', 'Học kỳ 1', 1, '2026-08-01', '2026-12-31', 'ACTIVE'
) mapping
JOIN academic_year ay ON ay.name = mapping.academic_year_name
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  start_date = VALUES(start_date),
  end_date = VALUES(end_date),
  status = VALUES(status);

/*
  Timetable stores one global slot_index per day:
  morning = 1..5, afternoon = 6..9.
  On UI, afternoon slots 6..9 are labelled afternoon periods 1..4.
*/
INSERT INTO lesson_slot (
  academic_year_id,
  shift,
  slot_index,
  start_time,
  end_time,
  status
)
SELECT
  ay.id,
  mapping.shift,
  mapping.slot_index,
  mapping.start_time,
  mapping.end_time,
  'ACTIVE'
FROM academic_year ay
JOIN (
  SELECT 'MORNING' AS shift, 1 AS slot_index, CAST('07:30:00' AS TIME) AS start_time, CAST('08:15:00' AS TIME) AS end_time
  UNION ALL SELECT 'MORNING', 2, CAST('08:25:00' AS TIME), CAST('09:10:00' AS TIME)
  UNION ALL SELECT 'MORNING', 3, CAST('09:20:00' AS TIME), CAST('10:05:00' AS TIME)
  UNION ALL SELECT 'MORNING', 4, CAST('10:15:00' AS TIME), CAST('11:00:00' AS TIME)
  UNION ALL SELECT 'MORNING', 5, CAST('11:10:00' AS TIME), CAST('11:55:00' AS TIME)
  UNION ALL SELECT 'AFTERNOON', 6, CAST('13:30:00' AS TIME), CAST('14:15:00' AS TIME)
  UNION ALL SELECT 'AFTERNOON', 7, CAST('14:25:00' AS TIME), CAST('15:10:00' AS TIME)
  UNION ALL SELECT 'AFTERNOON', 8, CAST('15:20:00' AS TIME), CAST('16:05:00' AS TIME)
  UNION ALL SELECT 'AFTERNOON', 9, CAST('16:15:00' AS TIME), CAST('17:00:00' AS TIME)
) mapping
WHERE ay.name = '2026-2027'
ON DUPLICATE KEY UPDATE
  start_time = VALUES(start_time),
  end_time = VALUES(end_time),
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

/* Grade 12 elective clusters: each student belongs to exactly one active group per semester. */
INSERT INTO subject_cluster (
  academic_year_id,
  semester_id,
  grade_level_id,
  cluster_code,
  cluster_name,
  status
)
SELECT
  ay.id,
  sem.id,
  gl.id,
  mapping.cluster_code,
  mapping.cluster_name,
  'ACTIVE'
FROM (
  SELECT 'TU_NHIEN' AS cluster_code, 'Cụm Tự nhiên' AS cluster_name
  UNION ALL SELECT 'XA_HOI', 'Cụm Xã hội'
) mapping
JOIN academic_year ay ON ay.name = '2026-2027'
JOIN semester sem ON sem.academic_year_id = ay.id AND sem.semester_index = 1
JOIN grade_level gl ON gl.level_number = 12
ON DUPLICATE KEY UPDATE
  cluster_name = VALUES(cluster_name),
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO subject_cluster_subject (
  subject_cluster_id,
  subject_id,
  periods_per_week,
  status
)
SELECT
  sc.id,
  s.id,
  2,
  'ACTIVE'
FROM (
  SELECT 'TU_NHIEN' AS cluster_code, 'VAT_LY' AS subject_code
  UNION ALL SELECT 'TU_NHIEN', 'HOA_HOC'
  UNION ALL SELECT 'TU_NHIEN', 'SINH_HOC'
  UNION ALL SELECT 'XA_HOI', 'LICH_SU'
  UNION ALL SELECT 'XA_HOI', 'DIA_LY'
  UNION ALL SELECT 'XA_HOI', 'GDCD'
) mapping
JOIN academic_year ay ON ay.name = '2026-2027'
JOIN semester sem ON sem.academic_year_id = ay.id AND sem.semester_index = 1
JOIN subject_cluster sc
  ON sc.academic_year_id = ay.id
 AND sc.semester_id = sem.id
 AND sc.cluster_code = mapping.cluster_code
JOIN subject s ON s.subject_code = mapping.subject_code
ON DUPLICATE KEY UPDATE
  periods_per_week = VALUES(periods_per_week),
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO study_group (
  class_id,
  subject_cluster_id,
  group_code,
  group_name,
  status
)
SELECT
  c.id,
  sc.id,
  mapping.group_code,
  mapping.group_name,
  'ACTIVE'
FROM (
  SELECT 'TU_NHIEN' AS cluster_code, '12A1-TN' AS group_code, '12A1 - Cụm Tự nhiên' AS group_name
  UNION ALL SELECT 'XA_HOI', '12A1-XH', '12A1 - Cụm Xã hội'
) mapping
JOIN academic_year ay ON ay.name = '2026-2027'
JOIN semester sem ON sem.academic_year_id = ay.id AND sem.semester_index = 1
JOIN class c ON c.academic_year_id = ay.id AND c.class_code = '12A1'
JOIN subject_cluster sc
  ON sc.academic_year_id = ay.id
 AND sc.semester_id = sem.id
 AND sc.cluster_code = mapping.cluster_code
ON DUPLICATE KEY UPDATE
  subject_cluster_id = VALUES(subject_cluster_id),
  group_name = VALUES(group_name),
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO student_study_group (
  student_id,
  study_group_id,
  academic_year_id,
  semester_id,
  effective_from,
  effective_to,
  status
)
SELECT
  st.id,
  sg.id,
  ay.id,
  sem.id,
  sem.start_date,
  sem.end_date,
  'ACTIVE'
FROM (
  SELECT 'STU_TEST_003' AS student_code, '12A1-TN' AS group_code
  UNION ALL SELECT 'STU_SEED_021', '12A1-TN'
  UNION ALL SELECT 'STU_SEED_023', '12A1-TN'
  UNION ALL SELECT 'STU_SEED_025', '12A1-TN'
  UNION ALL SELECT 'STU_SEED_027', '12A1-TN'
  UNION ALL SELECT 'STU_SEED_029', '12A1-TN'
  UNION ALL SELECT 'STU_SEED_022', '12A1-XH'
  UNION ALL SELECT 'STU_SEED_024', '12A1-XH'
  UNION ALL SELECT 'STU_SEED_026', '12A1-XH'
  UNION ALL SELECT 'STU_SEED_028', '12A1-XH'
  UNION ALL SELECT 'STU_SEED_030', '12A1-XH'
) mapping
JOIN academic_year ay ON ay.name = '2026-2027'
JOIN semester sem ON sem.academic_year_id = ay.id AND sem.semester_index = 1
JOIN student st ON st.student_code = mapping.student_code
JOIN class c ON c.id = st.current_class_id AND c.academic_year_id = ay.id AND c.class_code = '12A1'
JOIN study_group sg ON sg.class_id = c.id AND sg.group_code = mapping.group_code
ON DUPLICATE KEY UPDATE
  study_group_id = VALUES(study_group_id),
  academic_year_id = VALUES(academic_year_id),
  effective_from = VALUES(effective_from),
  effective_to = VALUES(effective_to),
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;

/*
  Subject Teachers teach their subject in the remaining classes; GDCD is
  elective for 12A1 only. Homeroom Teachers also own one main-subject
  assignment in their class:
  - teacher_test01: Toán - 10A1
  - teacher_test02: Ngữ văn - 11A1
  - parent_teacher_test01: Tiếng Anh - 12A1
*/
INSERT INTO teaching_assignment (
  teacher_id,
  class_id,
  subject_id,
  academic_year_id,
  semester_id,
  status
)
SELECT
  t.id,
  c.id,
  s.id,
  ay.id,
  sem.id,
  'ACTIVE'
FROM (
  SELECT 'NGU_VAN' AS subject_code, 'subject_teacher01' AS teacher_username
  UNION ALL SELECT 'TOAN', 'subject_teacher02'
  UNION ALL SELECT 'TIENG_ANH', 'subject_teacher03'
  UNION ALL SELECT 'LICH_SU', 'subject_teacher04'
  UNION ALL SELECT 'DIA_LY', 'subject_teacher05'
  UNION ALL SELECT 'VAT_LY', 'subject_teacher06'
  UNION ALL SELECT 'HOA_HOC', 'subject_teacher07'
  UNION ALL SELECT 'SINH_HOC', 'subject_teacher08'
  UNION ALL SELECT 'TIN_HOC', 'subject_teacher09'
  UNION ALL SELECT 'CONG_NGHE', 'subject_teacher10'
  UNION ALL SELECT 'GD_THE_CHAT', 'subject_teacher11'
  UNION ALL SELECT 'GD_QPAN', 'subject_teacher12'
  UNION ALL SELECT 'GDCD', 'subject_teacher13'
) mapping
JOIN academic_year ay ON ay.name = '2026-2027'
JOIN semester sem ON sem.academic_year_id = ay.id AND sem.semester_index = 1
JOIN class c
  ON c.academic_year_id = ay.id
 AND c.class_code IN ('10A1', '11A1', '12A1')
 AND (mapping.subject_code <> 'GDCD' OR c.class_code = '12A1')
JOIN subject s ON s.subject_code = mapping.subject_code
JOIN account a
  ON a.username = CASE
    WHEN c.class_code = '10A1' AND mapping.subject_code = 'TOAN'
      THEN 'teacher_test01'
    WHEN c.class_code = '11A1' AND mapping.subject_code = 'NGU_VAN'
      THEN 'teacher_test02'
    WHEN c.class_code = '12A1' AND mapping.subject_code = 'TIENG_ANH'
      THEN 'parent_teacher_test01'
    ELSE mapping.teacher_username
  END
JOIN teacher t ON t.account_id = a.id
ON DUPLICATE KEY UPDATE
  teacher_id = VALUES(teacher_id),
  academic_year_id = VALUES(academic_year_id),
  status = 'ACTIVE';

/* =========================================================
   Historical grade components and published component scores

   Each subject/semester has:
   - 2 DDG_TX scores with weight 1.
   - 1 DDG_GK score with weight 2.
   - 1 DDG_CK score with weight 3.

   Only students with COMPLETED historical class records receive
   grades. Current Grade 10 students intentionally receive none.
   ========================================================= */

INSERT INTO grade_component (
  code,
  name,
  weight,
  is_required,
  status
) VALUES
  ('DDG_TX', 'Đánh giá thường xuyên', 1.00, 1, 'ACTIVE'),
  ('DDG_GK', 'Đánh giá giữa kỳ', 2.00, 1, 'ACTIVE'),
  ('DDG_CK', 'Đánh giá cuối kỳ', 3.00, 1, 'ACTIVE')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  weight = VALUES(weight),
  is_required = VALUES(is_required),
  status = 'ACTIVE';

/* Historical subject assignments keep seeded grades within Teacher scope. */
INSERT INTO teaching_assignment (
  teacher_id,
  class_id,
  subject_id,
  academic_year_id,
  semester_id,
  status
)
SELECT
  t.id,
  c.id,
  s.id,
  ay.id,
  sem.id,
  'INACTIVE'
FROM (
  SELECT 'NGU_VAN' AS subject_code, 'subject_teacher01' AS teacher_username
  UNION ALL SELECT 'TOAN', 'subject_teacher02'
  UNION ALL SELECT 'TIENG_ANH', 'subject_teacher03'
  UNION ALL SELECT 'LICH_SU', 'subject_teacher04'
  UNION ALL SELECT 'DIA_LY', 'subject_teacher05'
  UNION ALL SELECT 'VAT_LY', 'subject_teacher06'
  UNION ALL SELECT 'HOA_HOC', 'subject_teacher07'
  UNION ALL SELECT 'SINH_HOC', 'subject_teacher08'
  UNION ALL SELECT 'TIN_HOC', 'subject_teacher09'
  UNION ALL SELECT 'CONG_NGHE', 'subject_teacher10'
  UNION ALL SELECT 'GD_THE_CHAT', 'subject_teacher11'
  UNION ALL SELECT 'GD_QPAN', 'subject_teacher12'
) mapping
JOIN academic_year ay ON ay.name IN ('2024-2025', '2025-2026')
JOIN semester sem ON sem.academic_year_id = ay.id
JOIN class c ON c.academic_year_id = ay.id
JOIN subject s ON s.subject_code = mapping.subject_code
JOIN account a ON a.username = mapping.teacher_username
JOIN teacher t ON t.account_id = a.id
ON DUPLICATE KEY UPDATE
  teacher_id = VALUES(teacher_id),
  academic_year_id = VALUES(academic_year_id),
  status = 'INACTIVE';

/* Rebuild only the historical component grades owned by this test seed. */
SET @myfschool_previous_safe_updates = @@SQL_SAFE_UPDATES;
SET SQL_SAFE_UPDATES = 0;

DELETE g
FROM grade g
JOIN semester sem ON sem.id = g.semester_id
JOIN academic_year ay ON ay.id = sem.academic_year_id
JOIN student s ON s.id = g.student_id
WHERE ay.name IN ('2024-2025', '2025-2026')
  AND g.id > 0
  AND (
    s.student_code LIKE 'STU_SEED_%'
    OR s.student_code LIKE 'STU_TEST_%'
  );

SET SQL_SAFE_UPDATES = @myfschool_previous_safe_updates;

INSERT INTO grade (
  student_id,
  class_id,
  subject_id,
  semester_id,
  grade_component_id,
  score,
  weight,
  attempt_no,
  is_published,
  entered_by_teacher_id,
  updated_by_account_id,
  published_at
)
SELECT
  sch.student_id,
  sch.class_id,
  subject.id,
  sem.id,
  component.id,
  CAST(
    5.0 + MOD(
      CRC32(CONCAT(
        student.student_code, '|',
        ay.name, '|',
        sem.semester_index, '|',
        subject.subject_code, '|',
        component_seed.component_code, '|',
        component_seed.attempt_no
      )),
      46
    ) / 10
    AS DECIMAL(4, 2)
  ),
  component.weight,
  component_seed.attempt_no,
  1,
  assignment.teacher_id,
  teacher_account.id,
  TIMESTAMP(sem.end_date, '17:00:00')
FROM student_class_history sch
JOIN student ON student.id = sch.student_id
JOIN academic_year ay
  ON ay.id = sch.academic_year_id
 AND ay.name IN ('2024-2025', '2025-2026')
JOIN class historical_class
  ON historical_class.id = sch.class_id
 AND historical_class.academic_year_id = ay.id
JOIN semester sem ON sem.academic_year_id = ay.id
CROSS JOIN (
  SELECT 'NGU_VAN' AS subject_code
  UNION ALL SELECT 'TOAN'
  UNION ALL SELECT 'TIENG_ANH'
  UNION ALL SELECT 'LICH_SU'
  UNION ALL SELECT 'DIA_LY'
  UNION ALL SELECT 'VAT_LY'
  UNION ALL SELECT 'HOA_HOC'
  UNION ALL SELECT 'SINH_HOC'
  UNION ALL SELECT 'TIN_HOC'
  UNION ALL SELECT 'CONG_NGHE'
  UNION ALL SELECT 'GD_THE_CHAT'
  UNION ALL SELECT 'GD_QPAN'
) subject_seed
JOIN subject ON subject.subject_code = subject_seed.subject_code
CROSS JOIN (
  SELECT 'DDG_TX' AS component_code, 1 AS attempt_no
  UNION ALL SELECT 'DDG_TX', 2
  UNION ALL SELECT 'DDG_GK', 1
  UNION ALL SELECT 'DDG_CK', 1
) component_seed
JOIN grade_component component ON component.code = component_seed.component_code
JOIN teaching_assignment assignment
  ON assignment.class_id = sch.class_id
 AND assignment.subject_id = subject.id
 AND assignment.academic_year_id = ay.id
 AND assignment.semester_id = sem.id
JOIN teacher ON teacher.id = assignment.teacher_id
JOIN account teacher_account ON teacher_account.id = teacher.account_id
WHERE sch.status = 'COMPLETED';

/* =========================================================
   Finalized historical learning-result snapshots

   Historical CLOSED years are persisted as snapshots so they
   remain queryable without recalculating them at application time.
   The ACTIVE year 2026-2027 is intentionally excluded: its
   snapshots must be finalized only after all required grades exist.
   ========================================================= */

/* Rebuild only historical snapshots owned by this test seed. */
SET @myfschool_previous_safe_updates = @@SQL_SAFE_UPDATES;
SET SQL_SAFE_UPDATES = 0;

DELETE learning_result
FROM learning_result
JOIN academic_year
  ON academic_year.id = learning_result.academic_year_id
JOIN student ON student.id = learning_result.student_id
WHERE academic_year.name IN ('2024-2025', '2025-2026')
  AND learning_result.id > 0
  AND (
    student.student_code LIKE 'STU_SEED_%'
    OR student.student_code LIKE 'STU_TEST_%'
  );

SET SQL_SAFE_UPDATES = @myfschool_previous_safe_updates;

DROP TEMPORARY TABLE IF EXISTS tmp_historical_subject_semester_result;
CREATE TEMPORARY TABLE tmp_historical_subject_semester_result AS
SELECT
  grade.student_id,
  grade.class_id,
  semester.academic_year_id,
  grade.semester_id,
  semester.semester_index,
  grade.subject_id,
  CAST(
    ROUND(
      SUM(grade.score * grade.weight) / SUM(grade.weight),
      2
    ) AS DECIMAL(4, 2)
  ) AS average_score
FROM grade
JOIN semester ON semester.id = grade.semester_id
JOIN academic_year
  ON academic_year.id = semester.academic_year_id
 AND academic_year.name IN ('2024-2025', '2025-2026')
 AND academic_year.status = 'CLOSED'
JOIN student ON student.id = grade.student_id
JOIN grade_component
  ON grade_component.id = grade.grade_component_id
WHERE grade.is_published = 1
  AND (
    student.student_code LIKE 'STU_SEED_%'
    OR student.student_code LIKE 'STU_TEST_%'
  )
GROUP BY
  grade.student_id,
  grade.class_id,
  semester.academic_year_id,
  grade.semester_id,
  semester.semester_index,
  grade.subject_id
HAVING SUM(grade_component.code = 'DDG_TX') >= 1
   AND SUM(grade_component.code = 'DDG_GK') = 1
   AND SUM(grade_component.code = 'DDG_CK') = 1;

DROP TEMPORARY TABLE IF EXISTS tmp_historical_semester_summary;
CREATE TEMPORARY TABLE tmp_historical_semester_summary AS
SELECT
  statistic.student_id,
  statistic.class_id,
  statistic.academic_year_id,
  statistic.semester_id,
  statistic.semester_index,
  statistic.average_score,
  CASE
    WHEN statistic.minimum_subject_score >= 7
     AND statistic.subjects_at_least_eight >= 6
     AND statistic.average_score >= 8
      THEN 'Xuất Sắc'
    WHEN statistic.minimum_subject_score >= 7
     AND statistic.subjects_at_least_eight >= 3
     AND statistic.average_score >= 7.5
      THEN 'Giỏi'
    WHEN statistic.minimum_subject_score >= 6
     AND statistic.subjects_at_least_eight >= 1
     AND statistic.average_score >= 6
      THEN 'Khá'
    WHEN statistic.minimum_subject_score >= 5
     AND statistic.average_score >= 5
      THEN 'Trung Bình'
    ELSE 'Yếu'
  END AS rank_label
FROM (
  SELECT
    subject_result.student_id,
    subject_result.class_id,
    subject_result.academic_year_id,
    subject_result.semester_id,
    subject_result.semester_index,
    CAST(
      ROUND(AVG(subject_result.average_score), 2)
      AS DECIMAL(4, 2)
    ) AS average_score,
    MIN(subject_result.average_score) AS minimum_subject_score,
    SUM(subject_result.average_score >= 8) AS subjects_at_least_eight
  FROM tmp_historical_subject_semester_result subject_result
  GROUP BY
    subject_result.student_id,
    subject_result.class_id,
    subject_result.academic_year_id,
    subject_result.semester_id,
    subject_result.semester_index
) statistic;

INSERT INTO learning_result (
  student_id,
  class_id,
  academic_year_id,
  semester_id,
  subject_id,
  result_type,
  average_score,
  rank_label,
  conduct_label,
  promotion_status,
  is_finalized,
  finalized_by_account_id,
  finalized_at,
  description
)
SELECT
  subject_result.student_id,
  subject_result.class_id,
  subject_result.academic_year_id,
  subject_result.semester_id,
  subject_result.subject_id,
  'SUBJECT_SEMESTER',
  subject_result.average_score,
  NULL,
  NULL,
  NULL,
  1,
  admin_account.id,
  TIMESTAMP(semester.end_date, '18:00:00'),
  NULL
FROM tmp_historical_subject_semester_result subject_result
JOIN semester ON semester.id = subject_result.semester_id
JOIN account admin_account ON admin_account.username = 'admin_test01'
ON DUPLICATE KEY UPDATE
  average_score = VALUES(average_score),
  rank_label = VALUES(rank_label),
  conduct_label = VALUES(conduct_label),
  promotion_status = VALUES(promotion_status),
  is_finalized = VALUES(is_finalized),
  finalized_by_account_id = VALUES(finalized_by_account_id),
  finalized_at = VALUES(finalized_at),
  description = VALUES(description),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO learning_result (
  student_id,
  class_id,
  academic_year_id,
  semester_id,
  subject_id,
  result_type,
  average_score,
  rank_label,
  conduct_label,
  promotion_status,
  is_finalized,
  finalized_by_account_id,
  finalized_at,
  description
)
SELECT
  summary.student_id,
  summary.class_id,
  summary.academic_year_id,
  summary.semester_id,
  NULL,
  'SEMESTER_SUMMARY',
  summary.average_score,
  summary.rank_label,
  'Tốt',
  NULL,
  1,
  admin_account.id,
  TIMESTAMP(semester.end_date, '18:00:00'),
  CONCAT(
    'Nhận xét học kỳ ',
    summary.semester_index,
    ': ',
    CASE summary.rank_label
      WHEN 'Xuất Sắc' THEN 'Kết quả học tập xuất sắc, tiếp tục phát huy.'
      WHEN 'Giỏi' THEN 'Kết quả học tập tốt, tiếp tục phát huy.'
      WHEN 'Khá' THEN 'Có cố gắng trong học tập, cần tiếp tục phát huy.'
      WHEN 'Trung Bình' THEN 'Cần chủ động và tập trung hơn trong học tập.'
      ELSE 'Cần cố gắng nhiều hơn và hoàn thành đầy đủ nhiệm vụ học tập.'
    END
  )
FROM tmp_historical_semester_summary summary
JOIN semester ON semester.id = summary.semester_id
JOIN account admin_account ON admin_account.username = 'admin_test01'
ON DUPLICATE KEY UPDATE
  average_score = VALUES(average_score),
  rank_label = VALUES(rank_label),
  conduct_label = VALUES(conduct_label),
  promotion_status = VALUES(promotion_status),
  is_finalized = VALUES(is_finalized),
  finalized_by_account_id = VALUES(finalized_by_account_id),
  finalized_at = VALUES(finalized_at),
  description = VALUES(description),
  updated_at = CURRENT_TIMESTAMP;

DROP TEMPORARY TABLE IF EXISTS tmp_historical_subject_annual_result;
CREATE TEMPORARY TABLE tmp_historical_subject_annual_result AS
SELECT
  semester_result.student_id,
  semester_result.class_id,
  semester_result.academic_year_id,
  semester_result.subject_id,
  CAST(
    ROUND(
      (
        MAX(
          CASE
            WHEN semester_result.semester_index = 1
              THEN semester_result.average_score
          END
        )
        + 2 * MAX(
          CASE
            WHEN semester_result.semester_index = 2
              THEN semester_result.average_score
          END
        )
      ) / 3,
      2
    ) AS DECIMAL(4, 2)
  ) AS average_score
FROM tmp_historical_subject_semester_result semester_result
GROUP BY
  semester_result.student_id,
  semester_result.class_id,
  semester_result.academic_year_id,
  semester_result.subject_id
HAVING COUNT(DISTINCT semester_result.semester_index) = 2;

DROP TEMPORARY TABLE IF EXISTS tmp_historical_annual_summary;
CREATE TEMPORARY TABLE tmp_historical_annual_summary AS
SELECT
  statistic.student_id,
  statistic.class_id,
  statistic.academic_year_id,
  statistic.average_score,
  CASE
    WHEN statistic.minimum_subject_score >= 7
     AND statistic.subjects_at_least_eight >= 6
     AND statistic.average_score >= 8
      THEN 'Xuất Sắc'
    WHEN statistic.minimum_subject_score >= 7
     AND statistic.subjects_at_least_eight >= 3
     AND statistic.average_score >= 7.5
      THEN 'Giỏi'
    WHEN statistic.minimum_subject_score >= 6
     AND statistic.subjects_at_least_eight >= 1
     AND statistic.average_score >= 6
      THEN 'Khá'
    WHEN statistic.minimum_subject_score >= 5
     AND statistic.average_score >= 5
      THEN 'Trung Bình'
    ELSE 'Yếu'
  END AS rank_label
FROM (
  SELECT
    subject_result.student_id,
    subject_result.class_id,
    subject_result.academic_year_id,
    CAST(
      ROUND(AVG(subject_result.average_score), 2)
      AS DECIMAL(4, 2)
    ) AS average_score,
    MIN(subject_result.average_score) AS minimum_subject_score,
    SUM(subject_result.average_score >= 8) AS subjects_at_least_eight
  FROM tmp_historical_subject_annual_result subject_result
  GROUP BY
    subject_result.student_id,
    subject_result.class_id,
    subject_result.academic_year_id
) statistic;

INSERT INTO learning_result (
  student_id,
  class_id,
  academic_year_id,
  semester_id,
  subject_id,
  result_type,
  average_score,
  rank_label,
  conduct_label,
  promotion_status,
  is_finalized,
  finalized_by_account_id,
  finalized_at,
  description
)
SELECT
  subject_result.student_id,
  subject_result.class_id,
  subject_result.academic_year_id,
  NULL,
  subject_result.subject_id,
  'SUBJECT_ANNUAL',
  subject_result.average_score,
  NULL,
  NULL,
  NULL,
  1,
  admin_account.id,
  TIMESTAMP(academic_year.end_date, '18:00:00'),
  NULL
FROM tmp_historical_subject_annual_result subject_result
JOIN academic_year ON academic_year.id = subject_result.academic_year_id
JOIN account admin_account ON admin_account.username = 'admin_test01'
ON DUPLICATE KEY UPDATE
  average_score = VALUES(average_score),
  rank_label = VALUES(rank_label),
  conduct_label = VALUES(conduct_label),
  promotion_status = VALUES(promotion_status),
  is_finalized = VALUES(is_finalized),
  finalized_by_account_id = VALUES(finalized_by_account_id),
  finalized_at = VALUES(finalized_at),
  description = VALUES(description),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO learning_result (
  student_id,
  class_id,
  academic_year_id,
  semester_id,
  subject_id,
  result_type,
  average_score,
  rank_label,
  conduct_label,
  promotion_status,
  is_finalized,
  finalized_by_account_id,
  finalized_at,
  description
)
SELECT
  summary.student_id,
  summary.class_id,
  summary.academic_year_id,
  NULL,
  NULL,
  'ANNUAL_SUMMARY',
  summary.average_score,
  summary.rank_label,
  'Tốt',
  CASE
    WHEN summary.rank_label = 'Yếu' THEN 'RETAINED'
    ELSE 'PROMOTED'
  END,
  1,
  admin_account.id,
  TIMESTAMP(academic_year.end_date, '18:00:00'),
  CASE summary.rank_label
    WHEN 'Xuất Sắc' THEN 'Hoàn thành xuất sắc chương trình năm học.'
    WHEN 'Giỏi' THEN 'Hoàn thành tốt chương trình năm học.'
    WHEN 'Khá' THEN 'Hoàn thành chương trình năm học và cần tiếp tục phát huy.'
    WHEN 'Trung Bình' THEN 'Hoàn thành chương trình năm học, cần chủ động hơn trong học tập.'
    ELSE 'Chưa đạt yêu cầu lên lớp, cần củng cố kiến thức và rèn luyện thêm.'
  END
FROM tmp_historical_annual_summary summary
JOIN academic_year ON academic_year.id = summary.academic_year_id
JOIN account admin_account ON admin_account.username = 'admin_test01'
ON DUPLICATE KEY UPDATE
  average_score = VALUES(average_score),
  rank_label = VALUES(rank_label),
  conduct_label = VALUES(conduct_label),
  promotion_status = VALUES(promotion_status),
  is_finalized = VALUES(is_finalized),
  finalized_by_account_id = VALUES(finalized_by_account_id),
  finalized_at = VALUES(finalized_at),
  description = VALUES(description),
  updated_at = CURRENT_TIMESTAMP;

DROP TEMPORARY TABLE IF EXISTS tmp_historical_annual_summary;
DROP TEMPORARY TABLE IF EXISTS tmp_historical_subject_annual_result;
DROP TEMPORARY TABLE IF EXISTS tmp_historical_semester_summary;
DROP TEMPORARY TABLE IF EXISTS tmp_historical_subject_semester_result;

/*
  Weekly common-class requirements; two fixed UI periods are not counted here.
  Grade 12 cluster periods are defined separately in subject_cluster_subject.
*/
SET @myfschool_previous_safe_updates = @@SQL_SAFE_UPDATES;
SET SQL_SAFE_UPDATES = 0;

DELETE spr
FROM subject_period_requirement spr
JOIN academic_year ay ON ay.id = spr.academic_year_id AND ay.name = '2026-2027'
JOIN semester sem ON sem.id = spr.semester_id AND sem.academic_year_id = ay.id AND sem.semester_index = 1
JOIN grade_level gl ON gl.id = spr.grade_level_id AND gl.level_number IN (10, 11, 12)
WHERE spr.id > 0;

SET SQL_SAFE_UPDATES = @myfschool_previous_safe_updates;

INSERT INTO subject_period_requirement (
  academic_year_id,
  semester_id,
  grade_level_id,
  subject_id,
  periods_per_week,
  status
)
SELECT
  ay.id,
  sem.id,
  gl.id,
  s.id,
  CASE gl.level_number WHEN 12 THEN mapping.grade_12_periods ELSE mapping.grade_10_11_periods END,
  'ACTIVE'
FROM (
  SELECT 'NGU_VAN' AS subject_code, 5 AS grade_10_11_periods, 6 AS grade_12_periods
  UNION ALL SELECT 'TOAN', 5, 6
  UNION ALL SELECT 'TIENG_ANH', 5, 5
  UNION ALL SELECT 'LICH_SU', 1, 0
  UNION ALL SELECT 'DIA_LY', 1, 0
  UNION ALL SELECT 'VAT_LY', 1, 0
  UNION ALL SELECT 'HOA_HOC', 1, 0
  UNION ALL SELECT 'SINH_HOC', 1, 0
  UNION ALL SELECT 'TIN_HOC', 2, 2
  UNION ALL SELECT 'CONG_NGHE', 2, 2
  UNION ALL SELECT 'GD_THE_CHAT', 2, 2
  UNION ALL SELECT 'GD_QPAN', 1, 2
) mapping
JOIN academic_year ay ON ay.name = '2026-2027'
JOIN semester sem ON sem.academic_year_id = ay.id AND sem.semester_index = 1
JOIN grade_level gl ON gl.level_number IN (10, 11, 12)
JOIN subject s ON s.subject_code = mapping.subject_code
WHERE CASE gl.level_number WHEN 12 THEN mapping.grade_12_periods ELSE mapping.grade_10_11_periods END > 0
ON DUPLICATE KEY UPDATE
  periods_per_week = VALUES(periods_per_week),
  status = 'ACTIVE',
  updated_at = CURRENT_TIMESTAMP;


/*
  Published HK1 timetables.
  Monday period 1 and Friday period 5 are absent by design:
  the UI renders Chào cờ and Sinh hoạt lớp as fixed homeroom periods.

  Afternoon rules:
  - Grades 10/11: Toán, Ngữ văn and Tiếng Anh have two periods/week each.
  - Grade 12: the three common subjects and each selected cluster subject have two periods/week.
  - Grade 12 cluster groups can study in parallel at the same class time.
*/
SET @myfschool_previous_safe_updates = @@SQL_SAFE_UPDATES;
SET SQL_SAFE_UPDATES = 0;

DELETE tt
FROM timetable tt
JOIN academic_year ay ON ay.id = tt.academic_year_id AND ay.name = '2026-2027'
JOIN semester sem ON sem.id = tt.semester_id AND sem.academic_year_id = ay.id AND sem.semester_index = 1
JOIN class c ON c.id = tt.class_id AND c.class_code IN ('10A1', '11A1', '12A1')
WHERE tt.id > 0;

SET SQL_SAFE_UPDATES = @myfschool_previous_safe_updates;

INSERT INTO timetable (
  academic_year_id,
  semester_id,
  class_id,
  study_group_id,
  subject_id,
  teacher_id,
  lesson_slot_id,
  day_of_week,
  slot_index,
  start_time,
  end_time,
  room,
  effective_from,
  effective_to,
  status
)
SELECT
  ay.id,
  sem.id,
  c.id,
  sg.id,
  s.id,
  ta.teacher_id,
  ls.id,
  schedule.day_of_week,
  schedule.slot_index,
  ls.start_time,
  ls.end_time,
  schedule.room,
  sem.start_date,
  sem.end_date,
  'PUBLISHED'
FROM (
  SELECT '10A1' AS class_code, NULL AS group_code, 'NGU_VAN' AS subject_code, 1 AS day_of_week, 2 AS slot_index, 'A101' AS room
  UNION ALL SELECT '10A1', NULL, 'TIENG_ANH', 1, 3, 'A101'
  UNION ALL SELECT '10A1', NULL, 'TOAN', 1, 4, 'A101'
  UNION ALL SELECT '10A1', NULL, 'GD_THE_CHAT', 1, 5, 'A101'
  UNION ALL SELECT '10A1', NULL, 'NGU_VAN', 2, 1, 'A101'
  UNION ALL SELECT '10A1', NULL, 'TIENG_ANH', 2, 2, 'A101'
  UNION ALL SELECT '10A1', NULL, 'TOAN', 2, 3, 'A101'
  UNION ALL SELECT '10A1', NULL, 'CONG_NGHE', 2, 4, 'A101'
  UNION ALL SELECT '10A1', NULL, 'DIA_LY', 3, 1, 'A101'
  UNION ALL SELECT '10A1', NULL, 'GD_QPAN', 3, 2, 'A101'
  UNION ALL SELECT '10A1', NULL, 'GD_THE_CHAT', 3, 3, 'A101'
  UNION ALL SELECT '10A1', NULL, 'HOA_HOC', 4, 1, 'A101'
  UNION ALL SELECT '10A1', NULL, 'LICH_SU', 4, 2, 'A101'
  UNION ALL SELECT '10A1', NULL, 'NGU_VAN', 4, 3, 'A101'
  UNION ALL SELECT '10A1', NULL, 'SINH_HOC', 4, 4, 'A101'
  UNION ALL SELECT '10A1', NULL, 'TIENG_ANH', 5, 1, 'A101'
  UNION ALL SELECT '10A1', NULL, 'TIN_HOC', 5, 2, 'A101'
  UNION ALL SELECT '10A1', NULL, 'TOAN', 5, 3, 'A101'
  UNION ALL SELECT '10A1', NULL, 'VAT_LY', 5, 4, 'A101'
  UNION ALL SELECT '11A1', NULL, 'TIENG_ANH', 1, 2, 'A201'
  UNION ALL SELECT '11A1', NULL, 'NGU_VAN', 1, 3, 'A201'
  UNION ALL SELECT '11A1', NULL, 'GD_THE_CHAT', 1, 4, 'A201'
  UNION ALL SELECT '11A1', NULL, 'TOAN', 1, 5, 'A201'
  UNION ALL SELECT '11A1', NULL, 'TIENG_ANH', 2, 1, 'A201'
  UNION ALL SELECT '11A1', NULL, 'NGU_VAN', 2, 2, 'A201'
  UNION ALL SELECT '11A1', NULL, 'CONG_NGHE', 2, 3, 'A201'
  UNION ALL SELECT '11A1', NULL, 'TOAN', 2, 4, 'A201'
  UNION ALL SELECT '11A1', NULL, 'GD_QPAN', 3, 1, 'A201'
  UNION ALL SELECT '11A1', NULL, 'DIA_LY', 3, 2, 'A201'
  UNION ALL SELECT '11A1', NULL, 'HOA_HOC', 3, 3, 'A201'
  UNION ALL SELECT '11A1', NULL, 'GD_THE_CHAT', 4, 1, 'A201'
  UNION ALL SELECT '11A1', NULL, 'NGU_VAN', 4, 2, 'A201'
  UNION ALL SELECT '11A1', NULL, 'LICH_SU', 4, 3, 'A201'
  UNION ALL SELECT '11A1', NULL, 'TIENG_ANH', 4, 4, 'A201'
  UNION ALL SELECT '11A1', NULL, 'SINH_HOC', 5, 1, 'A201'
  UNION ALL SELECT '11A1', NULL, 'TOAN', 5, 2, 'A201'
  UNION ALL SELECT '11A1', NULL, 'VAT_LY', 5, 3, 'A201'
  UNION ALL SELECT '11A1', NULL, 'TIN_HOC', 5, 4, 'A201'
  UNION ALL SELECT '12A1', NULL, 'TOAN', 1, 2, 'A301'
  UNION ALL SELECT '12A1', NULL, 'CONG_NGHE', 1, 3, 'A301'
  UNION ALL SELECT '12A1', NULL, 'NGU_VAN', 1, 4, 'A301'
  UNION ALL SELECT '12A1', NULL, 'TIENG_ANH', 1, 5, 'A301'
  UNION ALL SELECT '12A1', NULL, 'TOAN', 2, 1, 'A301'
  UNION ALL SELECT '12A1', NULL, 'GD_QPAN', 2, 2, 'A301'
  UNION ALL SELECT '12A1', NULL, 'NGU_VAN', 2, 3, 'A301'
  UNION ALL SELECT '12A1', NULL, 'GD_THE_CHAT', 2, 4, 'A301'
  UNION ALL SELECT '12A1', NULL, 'NGU_VAN', 3, 1, 'A301'
  UNION ALL SELECT '12A1', NULL, 'TIENG_ANH', 3, 2, 'A301'
  UNION ALL SELECT '12A1', NULL, 'TIN_HOC', 3, 3, 'A301'
  UNION ALL SELECT '12A1', NULL, 'TOAN', 4, 1, 'A301'
  UNION ALL SELECT '12A1', NULL, 'CONG_NGHE', 4, 2, 'A301'
  UNION ALL SELECT '12A1', NULL, 'GD_QPAN', 4, 3, 'A301'
  UNION ALL SELECT '12A1', NULL, 'GD_THE_CHAT', 4, 4, 'A301'
  UNION ALL SELECT '12A1', NULL, 'NGU_VAN', 5, 1, 'A301'
  UNION ALL SELECT '12A1', NULL, 'TIENG_ANH', 5, 2, 'A301'
  UNION ALL SELECT '12A1', NULL, 'TIN_HOC', 5, 3, 'A301'
  UNION ALL SELECT '12A1', NULL, 'TOAN', 5, 4, 'A301'
  UNION ALL SELECT '10A1', NULL, 'TOAN', 2, 6, 'A101'
  UNION ALL SELECT '10A1', NULL, 'NGU_VAN', 2, 7, 'A101'
  UNION ALL SELECT '10A1', NULL, 'TIENG_ANH', 4, 6, 'A101'
  UNION ALL SELECT '10A1', NULL, 'TOAN', 4, 7, 'A101'
  UNION ALL SELECT '10A1', NULL, 'NGU_VAN', 5, 6, 'A101'
  UNION ALL SELECT '10A1', NULL, 'TIENG_ANH', 5, 7, 'A101'
  UNION ALL SELECT '11A1', NULL, 'TOAN', 1, 6, 'A201'
  UNION ALL SELECT '11A1', NULL, 'NGU_VAN', 1, 7, 'A201'
  UNION ALL SELECT '11A1', NULL, 'TIENG_ANH', 3, 6, 'A201'
  UNION ALL SELECT '11A1', NULL, 'TOAN', 3, 7, 'A201'
  UNION ALL SELECT '11A1', NULL, 'TIENG_ANH', 5, 6, 'A201'
  UNION ALL SELECT '11A1', NULL, 'NGU_VAN', 5, 7, 'A201'
  UNION ALL SELECT '12A1', NULL, 'TIENG_ANH', 1, 6, 'A301'
  UNION ALL SELECT '12A1', NULL, 'TOAN', 1, 8, 'A301'
  UNION ALL SELECT '12A1', NULL, 'TIENG_ANH', 2, 7, 'A301'
  UNION ALL SELECT '12A1', NULL, 'NGU_VAN', 2, 8, 'A301'
  UNION ALL SELECT '12A1', NULL, 'NGU_VAN', 3, 7, 'A301'
  UNION ALL SELECT '12A1', NULL, 'TOAN', 4, 6, 'A301'
  UNION ALL SELECT '12A1', '12A1-TN', 'VAT_LY', 1, 7, 'A302'
  UNION ALL SELECT '12A1', '12A1-XH', 'LICH_SU', 1, 7, 'A303'
  UNION ALL SELECT '12A1', '12A1-TN', 'HOA_HOC', 2, 6, 'A302'
  UNION ALL SELECT '12A1', '12A1-XH', 'DIA_LY', 2, 6, 'A303'
  UNION ALL SELECT '12A1', '12A1-TN', 'SINH_HOC', 3, 6, 'A302'
  UNION ALL SELECT '12A1', '12A1-XH', 'GDCD', 3, 6, 'A303'
  UNION ALL SELECT '12A1', '12A1-TN', 'VAT_LY', 3, 8, 'A302'
  UNION ALL SELECT '12A1', '12A1-XH', 'LICH_SU', 3, 8, 'A303'
  UNION ALL SELECT '12A1', '12A1-TN', 'HOA_HOC', 4, 7, 'A302'
  UNION ALL SELECT '12A1', '12A1-XH', 'DIA_LY', 4, 7, 'A303'
  UNION ALL SELECT '12A1', '12A1-TN', 'SINH_HOC', 4, 8, 'A302'
  UNION ALL SELECT '12A1', '12A1-XH', 'GDCD', 4, 8, 'A303'
) schedule
JOIN academic_year ay ON ay.name = '2026-2027'
JOIN semester sem ON sem.academic_year_id = ay.id AND sem.semester_index = 1
JOIN class c ON c.academic_year_id = ay.id AND c.class_code = schedule.class_code
LEFT JOIN study_group sg
  ON sg.class_id = c.id
 AND sg.group_code = schedule.group_code
 AND sg.status = 'ACTIVE'
JOIN subject s ON s.subject_code = schedule.subject_code
JOIN teaching_assignment ta
  ON ta.academic_year_id = ay.id
 AND ta.semester_id = sem.id
 AND ta.class_id = c.id
 AND ta.subject_id = s.id
 AND ta.status = 'ACTIVE'
JOIN lesson_slot ls
  ON ls.academic_year_id = ay.id
 AND ls.slot_index = schedule.slot_index
 AND ls.shift = CASE
   WHEN schedule.slot_index <= 5 THEN 'MORNING'
   ELSE 'AFTERNOON'
 END
WHERE schedule.group_code IS NULL OR sg.id IS NOT NULL;

/* =========================================================
   School Event test data

   - Admin creates only SCHOOL events.
   - Each Teacher creates CLASS events only for their homeroom class.
   - Dates are relative to the execution date so UPCOMING/PAST
     filters always have visible data.
   - DRAFT and CANCELLED rows verify that viewers only receive
     PUBLISHED events.
   ========================================================= */

SET @myfschool_previous_safe_updates = @@SQL_SAFE_UPDATES;
SET SQL_SAFE_UPDATES = 0;

DELETE school_event
FROM school_event
JOIN account creator
  ON creator.id = school_event.created_by_account_id
WHERE school_event.id > 0
  AND creator.username IN (
    'admin_test01',
    'teacher_test01',
    'teacher_test02',
    'parent_teacher_test01'
  )
  AND school_event.title IN (
    'Lễ chào năm học mới',
    'Ngày hội thể thao toàn trường',
    'Họp phụ huynh lớp 10A1',
    'Sinh hoạt trải nghiệm lớp 10A1',
    'Ngày hội hướng nghiệp lớp 11A1',
    'Họp sơ kết lớp 11A1',
    'Họp phụ huynh lớp 12A1',
    'Tư vấn tuyển sinh lớp 12A1',
    'Kế hoạch ôn tập lớp 12A1',
    'Tham quan ngoại khóa toàn trường'
  );

SET SQL_SAFE_UPDATES = @myfschool_previous_safe_updates;

INSERT INTO school_event (
  title,
  description,
  scope,
  class_id,
  event_date,
  start_time,
  end_time,
  is_all_day,
  location,
  participation_type,
  status,
  created_by_account_id,
  published_at,
  cancellation_reason
)
SELECT
  event_seed.title,
  event_seed.description,
  event_seed.scope,
  CASE
    WHEN event_seed.scope = 'CLASS' THEN school_class.id
    ELSE NULL
  END,
  event_seed.event_date,
  event_seed.start_time,
  event_seed.end_time,
  event_seed.is_all_day,
  event_seed.location,
  event_seed.participation_type,
  event_seed.status,
  creator.id,
  event_seed.published_at,
  event_seed.cancellation_reason
FROM (
  SELECT
    'admin_test01' AS creator_username,
    'Lễ chào năm học mới' AS title,
    'Chương trình chào năm học mới dành cho toàn thể học sinh và giáo viên.' AS description,
    'SCHOOL' AS scope,
    CAST(NULL AS CHAR(20)) AS class_code,
    DATE_ADD(CURRENT_DATE, INTERVAL 3 DAY) AS event_date,
    CAST('07:30:00' AS TIME) AS start_time,
    CAST('10:00:00' AS TIME) AS end_time,
    0 AS is_all_day,
    'Sân trường' AS location,
    'REQUIRED' AS participation_type,
    'PUBLISHED' AS status,
    DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 2 DAY) AS published_at,
    CAST(NULL AS CHAR(255)) AS cancellation_reason
  UNION ALL SELECT
    'admin_test01',
    'Ngày hội thể thao toàn trường',
    'Ngày hội thể thao và giao lưu giữa các khối trong toàn trường.',
    'SCHOOL',
    NULL,
    DATE_SUB(CURRENT_DATE, INTERVAL 12 DAY),
    NULL,
    NULL,
    1,
    'Khu thể thao FPT School',
    'OPTIONAL',
    'PUBLISHED',
    DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 20 DAY),
    NULL
  UNION ALL SELECT
    'teacher_test01',
    'Họp phụ huynh lớp 10A1',
    'Trao đổi kế hoạch học tập và hoạt động của lớp 10A1.',
    'CLASS',
    '10A1',
    DATE_ADD(CURRENT_DATE, INTERVAL 5 DAY),
    CAST('08:00:00' AS TIME),
    CAST('10:00:00' AS TIME),
    0,
    'Lớp học 10A1',
    'REQUIRED',
    'PUBLISHED',
    DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 1 DAY),
    NULL
  UNION ALL SELECT
    'teacher_test01',
    'Sinh hoạt trải nghiệm lớp 10A1',
    'Hoạt động trải nghiệm và làm việc nhóm dành cho học sinh lớp 10A1.',
    'CLASS',
    '10A1',
    DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY),
    CAST('14:00:00' AS TIME),
    CAST('16:00:00' AS TIME),
    0,
    'Phòng đa năng',
    'OPTIONAL',
    'PUBLISHED',
    DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 14 DAY),
    NULL
  UNION ALL SELECT
    'teacher_test02',
    'Ngày hội hướng nghiệp lớp 11A1',
    'Tìm hiểu ngành nghề và định hướng lựa chọn môn học cho lớp 11A1.',
    'CLASS',
    '11A1',
    DATE_ADD(CURRENT_DATE, INTERVAL 8 DAY),
    NULL,
    NULL,
    1,
    'Hội trường',
    'OPTIONAL',
    'PUBLISHED',
    DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 1 DAY),
    NULL
  UNION ALL SELECT
    'teacher_test02',
    'Họp sơ kết lớp 11A1',
    'Sơ kết tình hình học tập và rèn luyện của lớp 11A1.',
    'CLASS',
    '11A1',
    DATE_SUB(CURRENT_DATE, INTERVAL 9 DAY),
    CAST('08:00:00' AS TIME),
    CAST('10:00:00' AS TIME),
    0,
    'Lớp học 11A1',
    'REQUIRED',
    'PUBLISHED',
    DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 16 DAY),
    NULL
  UNION ALL SELECT
    'parent_teacher_test01',
    'Họp phụ huynh lớp 12A1',
    'Họp phụ huynh về kế hoạch học tập và ôn thi của lớp 12A1.',
    'CLASS',
    '12A1',
    DATE_ADD(CURRENT_DATE, INTERVAL 2 DAY),
    CAST('08:00:00' AS TIME),
    CAST('11:30:00' AS TIME),
    0,
    'Lớp học 12A1',
    'REQUIRED',
    'PUBLISHED',
    DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 1 DAY),
    NULL
  UNION ALL SELECT
    'parent_teacher_test01',
    'Tư vấn tuyển sinh lớp 12A1',
    'Tư vấn lựa chọn ngành học và chuẩn bị hồ sơ tuyển sinh cho lớp 12A1.',
    'CLASS',
    '12A1',
    DATE_SUB(CURRENT_DATE, INTERVAL 5 DAY),
    CAST('13:30:00' AS TIME),
    CAST('16:00:00' AS TIME),
    0,
    'Phòng tư vấn hướng nghiệp',
    'OPTIONAL',
    'PUBLISHED',
    DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 12 DAY),
    NULL
  UNION ALL SELECT
    'parent_teacher_test01',
    'Kế hoạch ôn tập lớp 12A1',
    'Bản nháp kế hoạch ôn tập, chưa được phép hiển thị cho Parent và Student.',
    'CLASS',
    '12A1',
    DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY),
    CAST('14:00:00' AS TIME),
    CAST('16:00:00' AS TIME),
    0,
    'Lớp học 12A1',
    'REQUIRED',
    'DRAFT',
    NULL,
    NULL
  UNION ALL SELECT
    'admin_test01',
    'Tham quan ngoại khóa toàn trường',
    'Sự kiện đã hủy và không được hiển thị trong danh sách của người xem.',
    'SCHOOL',
    NULL,
    DATE_ADD(CURRENT_DATE, INTERVAL 10 DAY),
    CAST('07:00:00' AS TIME),
    CAST('17:00:00' AS TIME),
    0,
    'Bảo tàng Hà Nội',
    'OPTIONAL',
    'CANCELLED',
    DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 3 DAY),
    'Điều kiện tổ chức không bảo đảm.'
) event_seed
JOIN account creator
  ON creator.username = event_seed.creator_username
JOIN academic_year current_year
  ON current_year.name = '2026-2027'
LEFT JOIN class school_class
  ON school_class.academic_year_id = current_year.id
 AND school_class.class_code = event_seed.class_code
WHERE event_seed.scope = 'SCHOOL'
   OR school_class.id IS NOT NULL;

COMMIT;
