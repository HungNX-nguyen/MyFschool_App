/* =========================================================
   MyFschool - Login test accounts

   Run manually after database/script.sql.
   Test password for every account: Test@123456

   Login identifiers:
   - ADMIN:   admin_test01, admin_test02
   - TEACHER: 0919000001, 0919000002
   - PARENT:  0989000001, 0989000002
   - STUDENT: student_test01, student_test02
   - MULTI-ROLE PARENT + TEACHER: 0909000001

   This file intentionally creates only account and account_role data.
   It does not create Parent, Teacher, or Student business profiles.
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
WHERE username IN ('student_test01', 'student_test02')
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

COMMIT;
