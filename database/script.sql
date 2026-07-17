


/* =========================================================
   MyFschool Database Schema
   MySQL 8.0

   Ghi chú triển khai:
   - Dùng InnoDB để hỗ trợ transaction và foreign key.
   - Dùng utf8mb4 để lưu tiếng Việt và Unicode đầy đủ.
   - Các CHECK constraint được MySQL 8.0.16+ thực thi.
   - Một số rule nghiệp vụ phức tạp như:
     + chỉ có 1 năm học ACTIVE,
     + học kỳ nằm trong khoảng năm học,
     + timetable không overlap theo effective_from/effective_to,
     + teacher phải có teaching_assignment phù hợp,
     + parent phải có parent_student ACTIVE,
     + chỉ 1 student_class_history ACTIVE trong cùng năm học,
     cần được kiểm tra thêm ở backend hoặc trigger vì CHECK/UNIQUE thường không đủ biểu diễn.
   ========================================================= */

CREATE DATABASE IF NOT EXISTS myfschool
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE myfschool;

SET FOREIGN_KEY_CHECKS = 0;

/* Drop theo thứ tự ngược phụ thuộc để script có thể chạy lại từ đầu. */
DROP TABLE IF EXISTS audit_log;
DROP TABLE IF EXISTS notification_recipient;
DROP TABLE IF EXISTS notification;
DROP TABLE IF EXISTS school_event;
DROP TABLE IF EXISTS club_attendance;
DROP TABLE IF EXISTS club_activity;
DROP TABLE IF EXISTS club_member;
DROP TABLE IF EXISTS club;
DROP TABLE IF EXISTS payment_transaction;
DROP TABLE IF EXISTS invoice_item;
DROP TABLE IF EXISTS invoice;
DROP TABLE IF EXISTS tuition_period;
DROP TABLE IF EXISTS absence_record;
DROP TABLE IF EXISTS leave_request;
DROP TABLE IF EXISTS assignment_submission;
DROP TABLE IF EXISTS assignment;
DROP TABLE IF EXISTS exam_schedule;
DROP TABLE IF EXISTS learning_result;
DROP TABLE IF EXISTS grade;
DROP TABLE IF EXISTS grade_component;
DROP TABLE IF EXISTS timetable;
DROP TABLE IF EXISTS teacher_unavailability;
DROP TABLE IF EXISTS subject_period_requirement;
DROP TABLE IF EXISTS teaching_assignment;
DROP TABLE IF EXISTS student_study_group;
DROP TABLE IF EXISTS study_group;
DROP TABLE IF EXISTS subject_cluster_subject;
DROP TABLE IF EXISTS subject_cluster;
DROP TABLE IF EXISTS student_class_history;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS class;
DROP TABLE IF EXISTS subject;
DROP TABLE IF EXISTS lesson_slot;
DROP TABLE IF EXISTS grade_level;
DROP TABLE IF EXISTS semester;
DROP TABLE IF EXISTS academic_year;
DROP TABLE IF EXISTS parent_student;
DROP TABLE IF EXISTS teacher;
DROP TABLE IF EXISTS parent;
DROP TABLE IF EXISTS residential_area;
DROP TABLE IF EXISTS account_role;
DROP TABLE IF EXISTS account;

SET FOREIGN_KEY_CHECKS = 1;

/* =========================================================
   1. Identity & Access
   ========================================================= */

CREATE TABLE account (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NULL,
  email VARCHAR(255) NULL,
  phone VARCHAR(20) NULL,
  password_hash VARCHAR(255) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  last_login_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_account_username UNIQUE (username),
  CONSTRAINT uq_account_phone UNIQUE (phone),
  CONSTRAINT chk_account_status CHECK (status IN ('ACTIVE', 'LOCKED', 'INACTIVE', 'PASSWORD_RESET_REQUIRED'))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_account_email ON account (email);
CREATE INDEX idx_account_status ON account (status);

CREATE TABLE account_role (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  account_id BIGINT NOT NULL,
  role VARCHAR(30) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_account_role_account_role UNIQUE (account_id, role),
  CONSTRAINT chk_account_role_role CHECK (role IN ('PARENT', 'STUDENT', 'TEACHER', 'ADMIN')),
  CONSTRAINT chk_account_role_status CHECK (status IN ('ACTIVE', 'INACTIVE')),
  CONSTRAINT fk_account_role_account FOREIGN KEY (account_id) REFERENCES account (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_account_role_account_id ON account_role (account_id);
CREATE INDEX idx_account_role_role ON account_role (role);
CREATE INDEX idx_account_role_status ON account_role (status);

CREATE TABLE residential_area (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  area_code VARCHAR(50) NOT NULL,
  area_name VARCHAR(150) NOT NULL,
  description VARCHAR(500) NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_residential_area_code UNIQUE (area_code),
  CONSTRAINT chk_residential_area_status CHECK (status IN ('ACTIVE', 'INACTIVE'))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_residential_area_status ON residential_area (status);

CREATE TABLE parent (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  account_id BIGINT NOT NULL,
  full_name VARCHAR(150) NOT NULL,
  phone VARCHAR(20) NULL,
  email VARCHAR(255) NULL,
  address VARCHAR(500) NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_parent_account_id UNIQUE (account_id),
  CONSTRAINT chk_parent_status CHECK (status IN ('ACTIVE', 'INACTIVE')),
  CONSTRAINT fk_parent_account FOREIGN KEY (account_id) REFERENCES account (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_parent_phone ON parent (phone);
CREATE INDEX idx_parent_email ON parent (email);
CREATE INDEX idx_parent_status ON parent (status);

CREATE TABLE teacher (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  account_id BIGINT NOT NULL,
  teacher_code VARCHAR(50) NOT NULL,
  full_name VARCHAR(150) NOT NULL,
  phone VARCHAR(20) NULL,
  email VARCHAR(255) NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_teacher_account_id UNIQUE (account_id),
  CONSTRAINT uq_teacher_code UNIQUE (teacher_code),
  CONSTRAINT chk_teacher_status CHECK (status IN ('ACTIVE', 'INACTIVE')),
  CONSTRAINT fk_teacher_account FOREIGN KEY (account_id) REFERENCES account (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_teacher_phone ON teacher (phone);
CREATE INDEX idx_teacher_email ON teacher (email);
CREATE INDEX idx_teacher_status ON teacher (status);

/* =========================================================
   2. Academic Structure - bảng nền chưa phụ thuộc student/class vòng lặp
   ========================================================= */

CREATE TABLE academic_year (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'PLANNED',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_academic_year_name UNIQUE (name),
  CONSTRAINT chk_academic_year_date CHECK (start_date < end_date),
  CONSTRAINT chk_academic_year_status CHECK (status IN ('PLANNED', 'ACTIVE', 'CLOSED'))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_academic_year_status ON academic_year (status);

CREATE TABLE semester (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  academic_year_id BIGINT NOT NULL,
  name VARCHAR(50) NOT NULL,
  semester_index INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'PLANNED',

  CONSTRAINT uq_semester_year_index UNIQUE (academic_year_id, semester_index),
  CONSTRAINT chk_semester_index CHECK (semester_index IN (1, 2)),
  CONSTRAINT chk_semester_date CHECK (start_date < end_date),
  CONSTRAINT chk_semester_status CHECK (status IN ('PLANNED', 'ACTIVE', 'CLOSED')),
  CONSTRAINT fk_semester_academic_year FOREIGN KEY (academic_year_id) REFERENCES academic_year (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_semester_academic_year_id ON semester (academic_year_id);
CREATE INDEX idx_semester_status ON semester (status);

CREATE TABLE grade_level (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  level_number INT NOT NULL,
  description VARCHAR(255) NULL,

  CONSTRAINT uq_grade_level_number UNIQUE (level_number),
  CONSTRAINT chk_grade_level_number CHECK (level_number > 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE subject (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  subject_code VARCHAR(50) NOT NULL,
  subject_name VARCHAR(100) NOT NULL,
  description VARCHAR(255) NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',

  CONSTRAINT uq_subject_code UNIQUE (subject_code),
  CONSTRAINT chk_subject_status CHECK (status IN ('ACTIVE', 'INACTIVE'))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_subject_status ON subject (status);

CREATE TABLE subject_cluster (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  academic_year_id BIGINT NOT NULL,
  semester_id BIGINT NOT NULL,
  grade_level_id BIGINT NOT NULL,
  cluster_code VARCHAR(50) NOT NULL,
  cluster_name VARCHAR(100) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_subject_cluster_scope_code UNIQUE (
    academic_year_id,
    semester_id,
    grade_level_id,
    cluster_code
  ),
  CONSTRAINT chk_subject_cluster_status CHECK (status IN ('ACTIVE', 'INACTIVE')),
  CONSTRAINT fk_subject_cluster_academic_year FOREIGN KEY (academic_year_id) REFERENCES academic_year (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_subject_cluster_semester FOREIGN KEY (semester_id) REFERENCES semester (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_subject_cluster_grade_level FOREIGN KEY (grade_level_id) REFERENCES grade_level (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_subject_cluster_lookup ON subject_cluster (
  academic_year_id,
  semester_id,
  grade_level_id,
  status
);

CREATE TABLE subject_cluster_subject (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  subject_cluster_id BIGINT NOT NULL,
  subject_id BIGINT NOT NULL,
  periods_per_week INT NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_subject_cluster_subject UNIQUE (subject_cluster_id, subject_id),
  CONSTRAINT chk_subject_cluster_subject_periods CHECK (periods_per_week > 0),
  CONSTRAINT chk_subject_cluster_subject_status CHECK (status IN ('ACTIVE', 'INACTIVE')),
  CONSTRAINT fk_subject_cluster_subject_cluster FOREIGN KEY (subject_cluster_id) REFERENCES subject_cluster (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_subject_cluster_subject_subject FOREIGN KEY (subject_id) REFERENCES subject (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_subject_cluster_subject_subject_id ON subject_cluster_subject (subject_id);
CREATE INDEX idx_subject_cluster_subject_status ON subject_cluster_subject (status);

/* lesson_slot được database_design.md nhắc trong ERD, index và FK nhưng thiếu bảng mô tả cột chi tiết.
   Các cột dưới đây chỉ dùng đúng thông tin đã xuất hiện trong tài liệu: academic_year_id, shift, slot_index, start_time, end_time. */
CREATE TABLE lesson_slot (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  academic_year_id BIGINT NOT NULL,
  shift VARCHAR(20) NOT NULL DEFAULT 'MORNING',
  slot_index INT NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_lesson_slot_year_shift_slot UNIQUE (academic_year_id, shift, slot_index),
  CONSTRAINT chk_lesson_slot_shift CHECK (shift IN ('MORNING', 'AFTERNOON')),
  CONSTRAINT chk_lesson_slot_slot_index CHECK (slot_index > 0),
  CONSTRAINT chk_lesson_slot_time CHECK (start_time < end_time),
  CONSTRAINT chk_lesson_slot_status CHECK (status IN ('ACTIVE', 'INACTIVE')),
  CONSTRAINT fk_lesson_slot_academic_year FOREIGN KEY (academic_year_id) REFERENCES academic_year (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_lesson_slot_academic_year_shift ON lesson_slot (academic_year_id, shift);

CREATE TABLE class (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  academic_year_id BIGINT NOT NULL,
  grade_level_id BIGINT NOT NULL,
  homeroom_teacher_id BIGINT NULL,
  class_code VARCHAR(50) NOT NULL,
  class_name VARCHAR(100) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_class_year_code UNIQUE (academic_year_id, class_code),
  CONSTRAINT chk_class_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'CLOSED')),
  CONSTRAINT fk_class_academic_year FOREIGN KEY (academic_year_id) REFERENCES academic_year (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_class_grade_level FOREIGN KEY (grade_level_id) REFERENCES grade_level (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_class_homeroom_teacher FOREIGN KEY (homeroom_teacher_id) REFERENCES teacher (id)
    ON UPDATE CASCADE
    ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_class_academic_year_id ON class (academic_year_id);
CREATE INDEX idx_class_grade_level_id ON class (grade_level_id);
CREATE INDEX idx_class_homeroom_teacher_id ON class (homeroom_teacher_id);
CREATE INDEX idx_class_status ON class (status);

CREATE TABLE study_group (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  class_id BIGINT NOT NULL,
  subject_cluster_id BIGINT NOT NULL,
  group_code VARCHAR(50) NOT NULL,
  group_name VARCHAR(100) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_study_group_class_code UNIQUE (class_id, group_code),
  CONSTRAINT chk_study_group_status CHECK (status IN ('ACTIVE', 'INACTIVE')),
  CONSTRAINT fk_study_group_class FOREIGN KEY (class_id) REFERENCES class (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_study_group_subject_cluster FOREIGN KEY (subject_cluster_id) REFERENCES subject_cluster (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_study_group_class_id ON study_group (class_id);
CREATE INDEX idx_study_group_subject_cluster_id ON study_group (subject_cluster_id);
CREATE INDEX idx_study_group_status ON study_group (status);

/* =========================================================
   3. Student và quan hệ phụ thuộc class
   ========================================================= */

CREATE TABLE student (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  account_id BIGINT NULL,
  student_code VARCHAR(50) NOT NULL,
  full_name VARCHAR(150) NOT NULL,
  date_of_birth DATE NULL,
  gender VARCHAR(20) NULL,
  address VARCHAR(500) NULL,
  residential_area_id BIGINT NULL,
  current_class_id BIGINT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'PENDING_CLASS_ASSIGNMENT',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_student_account_id UNIQUE (account_id),
  CONSTRAINT uq_student_code UNIQUE (student_code),
  CONSTRAINT chk_student_gender CHECK (gender IS NULL OR gender IN ('MALE', 'FEMALE', 'OTHER')),
  CONSTRAINT chk_student_status CHECK (status IN ('PENDING_CLASS_ASSIGNMENT', 'ACTIVE', 'TRANSFERRED_OUT', 'GRADUATED', 'INACTIVE')),
  CONSTRAINT fk_student_account FOREIGN KEY (account_id) REFERENCES account (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_student_residential_area FOREIGN KEY (residential_area_id) REFERENCES residential_area (id)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  CONSTRAINT fk_student_current_class FOREIGN KEY (current_class_id) REFERENCES class (id)
    ON UPDATE CASCADE
    ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_student_full_name ON student (full_name);
CREATE INDEX idx_student_current_class_id ON student (current_class_id);
CREATE INDEX idx_student_residential_area_id ON student (residential_area_id);
CREATE INDEX idx_student_status ON student (status);

CREATE TABLE parent_student (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  parent_id BIGINT NOT NULL,
  student_id BIGINT NOT NULL,
  relationship VARCHAR(50) NULL,
  is_primary_contact TINYINT(1) NOT NULL DEFAULT 0,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_parent_student_parent_student UNIQUE (parent_id, student_id),
  CONSTRAINT chk_parent_student_primary CHECK (is_primary_contact IN (0, 1)),
  CONSTRAINT chk_parent_student_status CHECK (status IN ('ACTIVE', 'INACTIVE')),
  CONSTRAINT fk_parent_student_parent FOREIGN KEY (parent_id) REFERENCES parent (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_parent_student_student FOREIGN KEY (student_id) REFERENCES student (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_parent_student_parent_id ON parent_student (parent_id);
CREATE INDEX idx_parent_student_student_id ON parent_student (student_id);
CREATE INDEX idx_parent_student_status ON parent_student (status);

CREATE TABLE student_study_group (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  student_id BIGINT NOT NULL,
  study_group_id BIGINT NOT NULL,
  academic_year_id BIGINT NOT NULL,
  semester_id BIGINT NOT NULL,
  effective_from DATE NOT NULL,
  effective_to DATE NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_student_study_group_semester UNIQUE (student_id, semester_id),
  CONSTRAINT chk_student_study_group_date CHECK (
    effective_to IS NULL OR effective_from <= effective_to
  ),
  CONSTRAINT chk_student_study_group_status CHECK (status IN ('ACTIVE', 'INACTIVE')),
  CONSTRAINT fk_student_study_group_student FOREIGN KEY (student_id) REFERENCES student (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_student_study_group_group FOREIGN KEY (study_group_id) REFERENCES study_group (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_student_study_group_academic_year FOREIGN KEY (academic_year_id) REFERENCES academic_year (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_student_study_group_semester FOREIGN KEY (semester_id) REFERENCES semester (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_student_study_group_lookup ON student_study_group (
  student_id,
  academic_year_id,
  semester_id,
  status
);
CREATE INDEX idx_student_study_group_group_id ON student_study_group (study_group_id);

CREATE TABLE student_class_history (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  student_id BIGINT NOT NULL,
  class_id BIGINT NOT NULL,
  academic_year_id BIGINT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  note VARCHAR(500) NULL,

  CONSTRAINT chk_student_class_history_date CHECK (end_date IS NULL OR start_date <= end_date),
  CONSTRAINT chk_student_class_history_status CHECK (status IN ('ACTIVE', 'TRANSFERRED', 'COMPLETED', 'CANCELLED')),
  CONSTRAINT fk_sch_student FOREIGN KEY (student_id) REFERENCES student (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_sch_class FOREIGN KEY (class_id) REFERENCES class (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_sch_academic_year FOREIGN KEY (academic_year_id) REFERENCES academic_year (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_sch_student_id ON student_class_history (student_id);
CREATE INDEX idx_sch_class_id ON student_class_history (class_id);
CREATE INDEX idx_sch_academic_year_id ON student_class_history (academic_year_id);
CREATE INDEX idx_sch_student_year_status ON student_class_history (student_id, academic_year_id, status);

CREATE TABLE teaching_assignment (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  teacher_id BIGINT NOT NULL,
  class_id BIGINT NOT NULL,
  subject_id BIGINT NOT NULL,
  academic_year_id BIGINT NOT NULL,
  semester_id BIGINT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_teaching_assignment_main UNIQUE (class_id, subject_id, semester_id),
  CONSTRAINT chk_teaching_assignment_status CHECK (status IN ('ACTIVE', 'INACTIVE')),
  CONSTRAINT fk_teaching_assignment_teacher FOREIGN KEY (teacher_id) REFERENCES teacher (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_teaching_assignment_class FOREIGN KEY (class_id) REFERENCES class (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_teaching_assignment_subject FOREIGN KEY (subject_id) REFERENCES subject (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_teaching_assignment_academic_year FOREIGN KEY (academic_year_id) REFERENCES academic_year (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_teaching_assignment_semester FOREIGN KEY (semester_id) REFERENCES semester (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_teaching_assignment_teacher_id ON teaching_assignment (teacher_id);
CREATE INDEX idx_teaching_assignment_class_id ON teaching_assignment (class_id);
CREATE INDEX idx_teaching_assignment_subject_id ON teaching_assignment (subject_id);
CREATE INDEX idx_teaching_assignment_semester_id ON teaching_assignment (semester_id);
CREATE INDEX idx_teaching_assignment_status ON teaching_assignment (status);

CREATE TABLE subject_period_requirement (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  academic_year_id BIGINT NOT NULL,
  semester_id BIGINT NULL,
  grade_level_id BIGINT NOT NULL,
  subject_id BIGINT NOT NULL,
  periods_per_week INT NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_subject_period_requirement UNIQUE (academic_year_id, semester_id, grade_level_id, subject_id),
  CONSTRAINT chk_spr_periods CHECK (periods_per_week > 0),
  CONSTRAINT chk_spr_status CHECK (status IN ('ACTIVE', 'INACTIVE')),
  CONSTRAINT fk_spr_academic_year FOREIGN KEY (academic_year_id) REFERENCES academic_year (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_spr_semester FOREIGN KEY (semester_id) REFERENCES semester (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_spr_grade_level FOREIGN KEY (grade_level_id) REFERENCES grade_level (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_spr_subject FOREIGN KEY (subject_id) REFERENCES subject (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_spr_lookup ON subject_period_requirement (academic_year_id, semester_id, grade_level_id, subject_id);
CREATE INDEX idx_spr_status ON subject_period_requirement (status);

CREATE TABLE teacher_unavailability (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  teacher_id BIGINT NOT NULL,
  academic_year_id BIGINT NOT NULL,
  semester_id BIGINT NULL,
  day_of_week INT NOT NULL,
  lesson_slot_id BIGINT NULL,
  shift VARCHAR(20) NULL,
  effective_from DATE NOT NULL,
  effective_to DATE NULL,
  reason VARCHAR(500) NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT chk_teacher_unavailability_day CHECK (day_of_week BETWEEN 1 AND 7),
  CONSTRAINT chk_teacher_unavailability_shift CHECK (shift IS NULL OR shift IN ('MORNING', 'AFTERNOON')),
  CONSTRAINT chk_teacher_unavailability_date CHECK (effective_to IS NULL OR effective_from <= effective_to),
  CONSTRAINT chk_teacher_unavailability_status CHECK (status IN ('ACTIVE', 'INACTIVE')),
  CONSTRAINT fk_teacher_unavailability_teacher FOREIGN KEY (teacher_id) REFERENCES teacher (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_teacher_unavailability_academic_year FOREIGN KEY (academic_year_id) REFERENCES academic_year (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_teacher_unavailability_semester FOREIGN KEY (semester_id) REFERENCES semester (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_teacher_unavailability_lesson_slot FOREIGN KEY (lesson_slot_id) REFERENCES lesson_slot (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_teacher_unavailability_lookup ON teacher_unavailability (teacher_id, academic_year_id, semester_id, day_of_week, lesson_slot_id, status);

CREATE TABLE timetable (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  academic_year_id BIGINT NOT NULL,
  semester_id BIGINT NOT NULL,
  class_id BIGINT NOT NULL,
  study_group_id BIGINT NULL,
  subject_id BIGINT NOT NULL,
  teacher_id BIGINT NOT NULL,
  lesson_slot_id BIGINT NULL,
  day_of_week INT NOT NULL,
  slot_index INT NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  room VARCHAR(50) NULL,
  effective_from DATE NOT NULL,
  effective_to DATE NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',

  CONSTRAINT chk_timetable_day CHECK (day_of_week BETWEEN 1 AND 7),
  CONSTRAINT chk_timetable_slot CHECK (slot_index > 0),
  CONSTRAINT chk_timetable_time CHECK (start_time < end_time),
  CONSTRAINT chk_timetable_effective_date CHECK (effective_to IS NULL OR effective_from <= effective_to),
  CONSTRAINT chk_timetable_status CHECK (status IN ('DRAFT', 'PUBLISHED', 'ACTIVE', 'CANCELLED', 'INACTIVE')),
  CONSTRAINT fk_timetable_academic_year FOREIGN KEY (academic_year_id) REFERENCES academic_year (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_timetable_semester FOREIGN KEY (semester_id) REFERENCES semester (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_timetable_class FOREIGN KEY (class_id) REFERENCES class (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_timetable_study_group FOREIGN KEY (study_group_id) REFERENCES study_group (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_timetable_subject FOREIGN KEY (subject_id) REFERENCES subject (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_timetable_teacher FOREIGN KEY (teacher_id) REFERENCES teacher (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_timetable_lesson_slot FOREIGN KEY (lesson_slot_id) REFERENCES lesson_slot (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_timetable_class_id ON timetable (class_id);
CREATE INDEX idx_timetable_study_group_id ON timetable (study_group_id);
CREATE INDEX idx_timetable_teacher_id ON timetable (teacher_id);
CREATE INDEX idx_timetable_lesson_slot_id ON timetable (lesson_slot_id);
CREATE INDEX idx_timetable_semester_id ON timetable (semester_id);
CREATE INDEX idx_timetable_status ON timetable (status);
CREATE INDEX idx_timetable_day_slot ON timetable (day_of_week, slot_index);
CREATE INDEX idx_timetable_class_time ON timetable (class_id, day_of_week, slot_index, effective_from, effective_to);
CREATE INDEX idx_timetable_group_time ON timetable (study_group_id, day_of_week, slot_index, effective_from, effective_to);
CREATE INDEX idx_timetable_teacher_time ON timetable (teacher_id, day_of_week, slot_index, effective_from, effective_to);
CREATE INDEX idx_timetable_room_time ON timetable (room, day_of_week, slot_index, effective_from, effective_to);

/* =========================================================
   4. Learning Records
   ========================================================= */

CREATE TABLE grade_component (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(50) NOT NULL,
  name VARCHAR(100) NOT NULL,
  weight DECIMAL(5,2) NOT NULL,
  is_required TINYINT(1) NOT NULL DEFAULT 1,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',

  CONSTRAINT uq_grade_component_code UNIQUE (code),
  CONSTRAINT chk_grade_component_weight CHECK (weight > 0),
  CONSTRAINT chk_grade_component_required CHECK (is_required IN (0, 1)),
  CONSTRAINT chk_grade_component_status CHECK (status IN ('ACTIVE', 'INACTIVE'))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_grade_component_status ON grade_component (status);

CREATE TABLE grade (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  student_id BIGINT NOT NULL,
  class_id BIGINT NOT NULL,
  subject_id BIGINT NOT NULL,
  semester_id BIGINT NOT NULL,
  grade_component_id BIGINT NOT NULL,
  score DECIMAL(4,2) NOT NULL,
  weight DECIMAL(5,2) NOT NULL,
  attempt_no INT NOT NULL DEFAULT 1,
  is_published TINYINT(1) NOT NULL DEFAULT 0,
  entered_by_teacher_id BIGINT NOT NULL,
  updated_by_account_id BIGINT NULL,
  published_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT chk_grade_score CHECK (score >= 0 AND score <= 10),
  CONSTRAINT chk_grade_weight CHECK (weight > 0),
  CONSTRAINT chk_grade_attempt_no CHECK (attempt_no > 0),
  CONSTRAINT chk_grade_is_published CHECK (is_published IN (0, 1)),
  CONSTRAINT fk_grade_student FOREIGN KEY (student_id) REFERENCES student (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_grade_class FOREIGN KEY (class_id) REFERENCES class (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_grade_subject FOREIGN KEY (subject_id) REFERENCES subject (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_grade_semester FOREIGN KEY (semester_id) REFERENCES semester (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_grade_grade_component FOREIGN KEY (grade_component_id) REFERENCES grade_component (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_grade_entered_by_teacher FOREIGN KEY (entered_by_teacher_id) REFERENCES teacher (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_grade_updated_by_account FOREIGN KEY (updated_by_account_id) REFERENCES account (id)
    ON UPDATE CASCADE
    ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_grade_student_id ON grade (student_id);
CREATE INDEX idx_grade_class_id ON grade (class_id);
CREATE INDEX idx_grade_subject_id ON grade (subject_id);
CREATE INDEX idx_grade_semester_id ON grade (semester_id);
CREATE INDEX idx_grade_lookup ON grade (student_id, class_id, subject_id, semester_id);
CREATE INDEX idx_grade_teacher_id ON grade (entered_by_teacher_id);

CREATE TABLE learning_result (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  student_id BIGINT NOT NULL,
  class_id BIGINT NOT NULL,
  academic_year_id BIGINT NOT NULL,
  semester_id BIGINT NULL,
  subject_id BIGINT NULL,
  result_type VARCHAR(30) NOT NULL,
  average_score DECIMAL(4,2) NULL,
  rank_label VARCHAR(50) NULL,
  conduct_label VARCHAR(50) NULL,
  promotion_status VARCHAR(50) NULL,
  is_finalized TINYINT(1) NOT NULL DEFAULT 0,
  finalized_by_account_id BIGINT NULL,
  finalized_at DATETIME NULL,
  description TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT chk_learning_result_average CHECK (average_score IS NULL OR (average_score >= 0 AND average_score <= 10)),
  CONSTRAINT chk_learning_result_type CHECK (result_type IN ('SUBJECT_SEMESTER', 'SEMESTER_SUMMARY', 'SUBJECT_ANNUAL', 'ANNUAL_SUMMARY')),
  CONSTRAINT chk_learning_result_scope CHECK (
    (result_type = 'SUBJECT_SEMESTER' AND semester_id IS NOT NULL AND subject_id IS NOT NULL AND conduct_label IS NULL)
    OR (result_type = 'SEMESTER_SUMMARY' AND semester_id IS NOT NULL AND subject_id IS NULL)
    OR (result_type = 'SUBJECT_ANNUAL' AND semester_id IS NULL AND subject_id IS NOT NULL AND conduct_label IS NULL)
    OR (result_type = 'ANNUAL_SUMMARY' AND semester_id IS NULL AND subject_id IS NULL)
  ),
  CONSTRAINT chk_learning_result_promotion CHECK (promotion_status IS NULL OR promotion_status IN ('PROMOTED', 'RETAINED', 'REEXAM_REQUIRED', 'PENDING_REVIEW', 'GRADUATED')),
  CONSTRAINT chk_learning_result_finalized CHECK (is_finalized IN (0, 1)),
  CONSTRAINT fk_learning_result_student FOREIGN KEY (student_id) REFERENCES student (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_learning_result_class FOREIGN KEY (class_id) REFERENCES class (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_learning_result_academic_year FOREIGN KEY (academic_year_id) REFERENCES academic_year (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_learning_result_semester FOREIGN KEY (semester_id) REFERENCES semester (id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT,
  CONSTRAINT fk_learning_result_subject FOREIGN KEY (subject_id) REFERENCES subject (id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT,
  CONSTRAINT fk_learning_result_finalized_by FOREIGN KEY (finalized_by_account_id) REFERENCES account (id)
    ON UPDATE CASCADE
    ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_learning_result_student_id ON learning_result (student_id);
CREATE INDEX idx_learning_result_class_id ON learning_result (class_id);
CREATE INDEX idx_learning_result_year_semester ON learning_result (academic_year_id, semester_id);
CREATE INDEX idx_learning_result_subject_id ON learning_result (subject_id);
CREATE UNIQUE INDEX uq_learning_result_scope ON learning_result (
  student_id,
  class_id,
  academic_year_id,
  result_type,
  (COALESCE(semester_id, 0)),
  (COALESCE(subject_id, 0))
);

CREATE TABLE exam_schedule (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  academic_year_id BIGINT NOT NULL,
  semester_id BIGINT NOT NULL,
  class_id BIGINT NOT NULL,
  subject_id BIGINT NOT NULL,
  exam_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  room VARCHAR(50) NULL,
  note VARCHAR(500) NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'SCHEDULED',

  CONSTRAINT chk_exam_schedule_time CHECK (start_time < end_time),
  CONSTRAINT chk_exam_schedule_status CHECK (status IN ('SCHEDULED', 'CANCELLED', 'COMPLETED')),
  CONSTRAINT fk_exam_schedule_academic_year FOREIGN KEY (academic_year_id) REFERENCES academic_year (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_exam_schedule_semester FOREIGN KEY (semester_id) REFERENCES semester (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_exam_schedule_class FOREIGN KEY (class_id) REFERENCES class (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_exam_schedule_subject FOREIGN KEY (subject_id) REFERENCES subject (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_exam_schedule_class_date ON exam_schedule (class_id, exam_date);
CREATE INDEX idx_exam_schedule_subject_id ON exam_schedule (subject_id);
CREATE INDEX idx_exam_schedule_status ON exam_schedule (status);

CREATE TABLE assignment (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  class_id BIGINT NOT NULL,
  subject_id BIGINT NOT NULL,
  teacher_id BIGINT NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT NULL,
  due_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT chk_assignment_status CHECK (status IN ('DRAFT', 'PUBLISHED', 'CLOSED')),
  CONSTRAINT fk_assignment_class FOREIGN KEY (class_id) REFERENCES class (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_assignment_subject FOREIGN KEY (subject_id) REFERENCES subject (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_assignment_teacher FOREIGN KEY (teacher_id) REFERENCES teacher (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_assignment_class_id ON assignment (class_id);
CREATE INDEX idx_assignment_subject_id ON assignment (subject_id);
CREATE INDEX idx_assignment_teacher_id ON assignment (teacher_id);
CREATE INDEX idx_assignment_status ON assignment (status);

CREATE TABLE assignment_submission (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  assignment_id BIGINT NOT NULL,
  student_id BIGINT NOT NULL,
  content TEXT NULL,
  file_url VARCHAR(1000) NULL,
  submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  score DECIMAL(4,2) NULL,
  feedback TEXT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'SUBMITTED',

  CONSTRAINT uq_assignment_submission_assignment_student UNIQUE (assignment_id, student_id),
  CONSTRAINT chk_assignment_submission_score CHECK (score IS NULL OR (score >= 0 AND score <= 10)),
  CONSTRAINT chk_assignment_submission_status CHECK (status IN ('SUBMITTED', 'LATE', 'GRADED', 'RETURNED')),
  CONSTRAINT fk_assignment_submission_assignment FOREIGN KEY (assignment_id) REFERENCES assignment (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_assignment_submission_student FOREIGN KEY (student_id) REFERENCES student (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_assignment_submission_student_id ON assignment_submission (student_id);
CREATE INDEX idx_assignment_submission_status ON assignment_submission (status);

/* =========================================================
   5. Leave & Absence
   ========================================================= */

CREATE TABLE leave_request (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  student_id BIGINT NOT NULL,
  parent_id BIGINT NOT NULL,
  class_id BIGINT NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  reason TEXT NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
  reviewed_by_teacher_id BIGINT NULL,
  reviewed_at DATETIME NULL,
  review_note TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT chk_leave_request_date CHECK (from_date <= to_date),
  CONSTRAINT chk_leave_request_status CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED')),
  CONSTRAINT fk_leave_request_student FOREIGN KEY (student_id) REFERENCES student (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_leave_request_parent FOREIGN KEY (parent_id) REFERENCES parent (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_leave_request_class FOREIGN KEY (class_id) REFERENCES class (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_leave_request_reviewed_by_teacher FOREIGN KEY (reviewed_by_teacher_id) REFERENCES teacher (id)
    ON UPDATE CASCADE
    ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_leave_request_student_id ON leave_request (student_id);
CREATE INDEX idx_leave_request_parent_id ON leave_request (parent_id);
CREATE INDEX idx_leave_request_class_id ON leave_request (class_id);
CREATE INDEX idx_leave_request_status ON leave_request (status);

CREATE TABLE absence_record (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  student_id BIGINT NOT NULL,
  class_id BIGINT NOT NULL,
  absence_date DATE NOT NULL,
  status VARCHAR(30) NOT NULL,
  source VARCHAR(30) NOT NULL,
  leave_request_id BIGINT NULL,
  recorded_by_teacher_id BIGINT NULL,
  note TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_absence_record_student_date_source UNIQUE (student_id, absence_date, source),
  CONSTRAINT chk_absence_record_status CHECK (status IN ('EXCUSED_ABSENT', 'UNEXCUSED_ABSENT', 'PENDING_VERIFICATION')),
  CONSTRAINT chk_absence_record_source CHECK (source IN ('LEAVE_REQUEST', 'TEACHER_REPORT', 'SYSTEM')),
  CONSTRAINT fk_absence_record_student FOREIGN KEY (student_id) REFERENCES student (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_absence_record_class FOREIGN KEY (class_id) REFERENCES class (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_absence_record_leave_request FOREIGN KEY (leave_request_id) REFERENCES leave_request (id)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  CONSTRAINT fk_absence_record_recorded_by_teacher FOREIGN KEY (recorded_by_teacher_id) REFERENCES teacher (id)
    ON UPDATE CASCADE
    ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_absence_record_student_id ON absence_record (student_id);
CREATE INDEX idx_absence_record_class_id ON absence_record (class_id);
CREATE INDEX idx_absence_record_absence_date ON absence_record (absence_date);
CREATE INDEX idx_absence_record_lookup ON absence_record (student_id, class_id, absence_date);

/* =========================================================
   6. Finance
   ========================================================= */

CREATE TABLE tuition_period (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  academic_year_id BIGINT NOT NULL,
  semester_id BIGINT NULL,
  name VARCHAR(150) NOT NULL,
  description TEXT NULL,
  due_date DATE NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
  created_by_account_id BIGINT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT chk_tuition_period_status CHECK (status IN ('DRAFT', 'PUBLISHED', 'CLOSED', 'CANCELLED')),
  CONSTRAINT fk_tuition_period_academic_year FOREIGN KEY (academic_year_id) REFERENCES academic_year (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_tuition_period_semester FOREIGN KEY (semester_id) REFERENCES semester (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_tuition_period_created_by FOREIGN KEY (created_by_account_id) REFERENCES account (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_tuition_period_academic_year_id ON tuition_period (academic_year_id);
CREATE INDEX idx_tuition_period_semester_id ON tuition_period (semester_id);
CREATE INDEX idx_tuition_period_status ON tuition_period (status);

CREATE TABLE invoice (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  invoice_code VARCHAR(50) NOT NULL,
  tuition_period_id BIGINT NOT NULL,
  student_id BIGINT NOT NULL,
  class_id BIGINT NOT NULL,
  total_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  paid_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  status VARCHAR(30) NOT NULL DEFAULT 'UNPAID',
  issued_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  due_date DATE NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_invoice_code UNIQUE (invoice_code),
  CONSTRAINT uq_invoice_period_student UNIQUE (tuition_period_id, student_id),
  CONSTRAINT chk_invoice_amount CHECK (total_amount >= 0 AND paid_amount >= 0 AND paid_amount <= total_amount),
  CONSTRAINT chk_invoice_status CHECK (status IN ('UNPAID', 'PROCESSING', 'PAID', 'OVERDUE', 'CANCELLED')),
  CONSTRAINT fk_invoice_tuition_period FOREIGN KEY (tuition_period_id) REFERENCES tuition_period (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_invoice_student FOREIGN KEY (student_id) REFERENCES student (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_invoice_class FOREIGN KEY (class_id) REFERENCES class (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_invoice_student_id ON invoice (student_id);
CREATE INDEX idx_invoice_tuition_period_id ON invoice (tuition_period_id);
CREATE INDEX idx_invoice_status ON invoice (status);

CREATE TABLE invoice_item (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  invoice_id BIGINT NOT NULL,
  item_name VARCHAR(150) NOT NULL,
  description VARCHAR(500) NULL,
  amount DECIMAL(15,2) NOT NULL,

  CONSTRAINT chk_invoice_item_amount CHECK (amount >= 0),
  CONSTRAINT fk_invoice_item_invoice FOREIGN KEY (invoice_id) REFERENCES invoice (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_invoice_item_invoice_id ON invoice_item (invoice_id);

CREATE TABLE payment_transaction (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  invoice_id BIGINT NOT NULL,
  payer_account_id BIGINT NULL,
  provider VARCHAR(50) NOT NULL,
  provider_transaction_id VARCHAR(150) NULL,
  amount DECIMAL(15,2) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
  paid_at DATETIME NULL,
  raw_response TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT chk_payment_transaction_provider CHECK (provider IN ('VNPAY', 'SEPAY')),
  CONSTRAINT chk_payment_transaction_amount CHECK (amount > 0),
  CONSTRAINT chk_payment_transaction_status CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED', 'CANCELLED', 'REFUNDED')),
  CONSTRAINT fk_payment_transaction_invoice FOREIGN KEY (invoice_id) REFERENCES invoice (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_payment_transaction_payer FOREIGN KEY (payer_account_id) REFERENCES account (id)
    ON UPDATE CASCADE
    ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_payment_transaction_invoice_id ON payment_transaction (invoice_id);
CREATE INDEX idx_payment_transaction_provider_transaction_id ON payment_transaction (provider_transaction_id);
CREATE INDEX idx_payment_transaction_status ON payment_transaction (status);

/* =========================================================
   7. Club
   ========================================================= */

CREATE TABLE club (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  club_code VARCHAR(50) NOT NULL,
  club_name VARCHAR(150) NOT NULL,
  description TEXT NULL,
  mentor_teacher_id BIGINT NULL,
  max_members INT NULL,
  registration_open_at DATETIME NULL,
  registration_close_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_club_code UNIQUE (club_code),
  CONSTRAINT chk_club_max_members CHECK (max_members IS NULL OR max_members > 0),
  CONSTRAINT chk_club_registration_time CHECK (registration_close_at IS NULL OR registration_open_at IS NULL OR registration_open_at <= registration_close_at),
  CONSTRAINT chk_club_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'CLOSED')),
  CONSTRAINT fk_club_mentor_teacher FOREIGN KEY (mentor_teacher_id) REFERENCES teacher (id)
    ON UPDATE CASCADE
    ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_club_mentor_teacher_id ON club (mentor_teacher_id);
CREATE INDEX idx_club_status ON club (status);

CREATE TABLE club_member (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  club_id BIGINT NOT NULL,
  student_id BIGINT NOT NULL,
  registered_by_parent_id BIGINT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
  reviewed_by_teacher_id BIGINT NULL,
  reviewed_at DATETIME NULL,
  joined_at DATETIME NULL,
  left_at DATETIME NULL,
  note TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_club_member_club_student UNIQUE (club_id, student_id),
  CONSTRAINT chk_club_member_status CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'LEFT')),
  CONSTRAINT chk_club_member_left_after_join CHECK (left_at IS NULL OR joined_at IS NULL OR joined_at <= left_at),
  CONSTRAINT fk_club_member_club FOREIGN KEY (club_id) REFERENCES club (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_club_member_student FOREIGN KEY (student_id) REFERENCES student (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_club_member_registered_by_parent FOREIGN KEY (registered_by_parent_id) REFERENCES parent (id)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  CONSTRAINT fk_club_member_reviewed_by_teacher FOREIGN KEY (reviewed_by_teacher_id) REFERENCES teacher (id)
    ON UPDATE CASCADE
    ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_club_member_club_id ON club_member (club_id);
CREATE INDEX idx_club_member_student_id ON club_member (student_id);
CREATE INDEX idx_club_member_status ON club_member (status);

CREATE TABLE club_activity (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  club_id BIGINT NOT NULL,
  title VARCHAR(150) NOT NULL,
  description TEXT NULL,
  activity_date DATE NOT NULL,
  start_time TIME NULL,
  end_time TIME NULL,
  location VARCHAR(150) NULL,
  created_by_teacher_id BIGINT NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'SCHEDULED',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT chk_club_activity_time CHECK (end_time IS NULL OR start_time IS NULL OR start_time < end_time),
  CONSTRAINT chk_club_activity_status CHECK (status IN ('SCHEDULED', 'CANCELLED', 'COMPLETED')),
  CONSTRAINT fk_club_activity_club FOREIGN KEY (club_id) REFERENCES club (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_club_activity_created_by_teacher FOREIGN KEY (created_by_teacher_id) REFERENCES teacher (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_club_activity_club_id ON club_activity (club_id);
CREATE INDEX idx_club_activity_date ON club_activity (activity_date);
CREATE INDEX idx_club_activity_status ON club_activity (status);

CREATE TABLE club_attendance (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  club_activity_id BIGINT NOT NULL,
  student_id BIGINT NOT NULL,
  status VARCHAR(30) NOT NULL,
  recorded_by_teacher_id BIGINT NOT NULL,
  note VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_club_attendance_activity_student UNIQUE (club_activity_id, student_id),
  CONSTRAINT chk_club_attendance_status CHECK (status IN ('PRESENT', 'ABSENT', 'EXCUSED')),
  CONSTRAINT fk_club_attendance_activity FOREIGN KEY (club_activity_id) REFERENCES club_activity (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_club_attendance_student FOREIGN KEY (student_id) REFERENCES student (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_club_attendance_recorded_by_teacher FOREIGN KEY (recorded_by_teacher_id) REFERENCES teacher (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_club_attendance_student_id ON club_attendance (student_id);

/* =========================================================
   8. School Event
   ========================================================= */

CREATE TABLE school_event (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT NULL,
  scope VARCHAR(20) NOT NULL,
  class_id BIGINT NULL,
  event_date DATE NOT NULL,
  start_time TIME NULL,
  end_time TIME NULL,
  is_all_day TINYINT(1) NOT NULL DEFAULT 0,
  location VARCHAR(255) NULL,
  participation_type VARCHAR(20) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
  created_by_account_id BIGINT NOT NULL,
  published_at DATETIME NULL,
  cancellation_reason TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT chk_school_event_scope CHECK (scope IN ('SCHOOL', 'CLASS')),
  CONSTRAINT chk_school_event_scope_class CHECK (
    (scope = 'SCHOOL' AND class_id IS NULL)
    OR (scope = 'CLASS' AND class_id IS NOT NULL)
  ),
  CONSTRAINT chk_school_event_time CHECK (end_time IS NULL OR start_time IS NULL OR start_time < end_time),
  CONSTRAINT chk_school_event_is_all_day CHECK (is_all_day IN (0, 1)),
  CONSTRAINT chk_school_event_all_day_time CHECK (
    (is_all_day = 1 AND start_time IS NULL AND end_time IS NULL)
    OR (is_all_day = 0 AND start_time IS NOT NULL)
  ),
  CONSTRAINT chk_school_event_participation_type CHECK (participation_type IN ('REQUIRED', 'OPTIONAL')),
  CONSTRAINT chk_school_event_status CHECK (status IN ('DRAFT', 'PUBLISHED', 'CANCELLED', 'COMPLETED')),
  CONSTRAINT fk_school_event_class FOREIGN KEY (class_id) REFERENCES class (id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_school_event_created_by FOREIGN KEY (created_by_account_id) REFERENCES account (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_school_event_class_id ON school_event (class_id);
CREATE INDEX idx_school_event_created_by_account_id ON school_event (created_by_account_id);
CREATE INDEX idx_school_event_scope_status_date ON school_event (scope, status, event_date);
CREATE INDEX idx_school_event_class_status_date ON school_event (class_id, status, event_date);

/* =========================================================
   9. Communication
   ========================================================= */

CREATE TABLE notification (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  type VARCHAR(50) NOT NULL,
  related_student_id BIGINT NULL,
  related_entity_type VARCHAR(50) NULL,
  related_entity_id BIGINT NULL,
  created_by_account_id BIGINT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT chk_notification_type CHECK (type IN ('GRADE', 'LEAVE', 'ABSENCE', 'TUITION', 'CLUB', 'ANNOUNCEMENT', 'EVENT', 'SYSTEM')),
  CONSTRAINT fk_notification_related_student FOREIGN KEY (related_student_id) REFERENCES student (id)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  CONSTRAINT fk_notification_created_by FOREIGN KEY (created_by_account_id) REFERENCES account (id)
    ON UPDATE CASCADE
    ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_notification_type ON notification (type);
CREATE INDEX idx_notification_related_student_id ON notification (related_student_id);
CREATE INDEX idx_notification_related_entity ON notification (related_entity_type, related_entity_id);

CREATE TABLE notification_recipient (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  notification_id BIGINT NOT NULL,
  account_id BIGINT NOT NULL,
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  read_at DATETIME NULL,
  delivery_status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_notification_recipient_notification_account UNIQUE (notification_id, account_id),
  CONSTRAINT chk_notification_recipient_is_read CHECK (is_read IN (0, 1)),
  CONSTRAINT chk_notification_recipient_delivery_status CHECK (delivery_status IN ('PENDING', 'SENT', 'FAILED')),
  CONSTRAINT fk_notification_recipient_notification FOREIGN KEY (notification_id) REFERENCES notification (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_notification_recipient_account FOREIGN KEY (account_id) REFERENCES account (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_notification_recipient_account_read ON notification_recipient (account_id, is_read);
CREATE INDEX idx_notification_recipient_delivery_status ON notification_recipient (delivery_status);

/* =========================================================
   10. Audit
   ========================================================= */

CREATE TABLE audit_log (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  actor_account_id BIGINT NOT NULL,
  actor_role VARCHAR(30) NOT NULL,
  action VARCHAR(50) NOT NULL,
  module VARCHAR(50) NOT NULL,
  entity_type VARCHAR(100) NOT NULL,
  entity_id BIGINT NOT NULL,
  old_value TEXT NULL,
  new_value TEXT NULL,
  reason TEXT NULL,
  ip_address VARCHAR(100) NULL,
  user_agent VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT chk_audit_log_actor_role CHECK (actor_role IN ('PARENT', 'STUDENT', 'TEACHER', 'ADMIN')),
  CONSTRAINT fk_audit_log_actor_account FOREIGN KEY (actor_account_id) REFERENCES account (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_audit_log_actor_account_id ON audit_log (actor_account_id);
CREATE INDEX idx_audit_log_module ON audit_log (module);
CREATE INDEX idx_audit_log_entity ON audit_log (entity_type, entity_id);
CREATE INDEX idx_audit_log_created_at ON audit_log (created_at);

/* =========================================================
   Ghi chú các thông tin tài liệu chưa đủ để ràng buộc hoàn toàn bằng SQL
   =========================================================
   1. database_design.md nhắc class.max_students trong business rule nhưng bảng class không định nghĩa cột max_students,
      nên script không thêm cột này để tránh tự ý mở rộng schema.
   2. subject_grade_policy và system_setting nằm trong nhóm cấu hình đề xuất/giai đoạn sau,
      không thuộc nhóm bảng chính bắt buộc nên không tạo trong script chính thức này.
   3. Messaging/Chat là module mở rộng giai đoạn sau, không thuộc phạm vi database lõi ban đầu nên không tạo bảng.
   4. Các ràng buộc phụ thuộc dữ liệu liên bảng phức tạp cần backend/trigger xử lý:
      - role account phải khớp profile parent/student/teacher,
      - semester date nằm trong academic_year,
      - class không vượt sĩ số tối đa nếu sau này có max_students,
      - teacher timetable phải có teaching_assignment phù hợp,
      - parent tạo leave_request/club_member phải có parent_student ACTIVE,
      - mentor duyệt CLB phải là mentor của club,
      - ADMIN chỉ tạo school_event phạm vi SCHOOL,
      - TEACHER chỉ tạo school_event phạm vi CLASS cho lớp mình đang làm GVCN,
      - trạng thái chuyển tiếp hợp lệ theo từng nghiệp vụ.
   ========================================================= */
