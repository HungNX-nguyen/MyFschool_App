/*
  One-time repair for an existing MyFschool database created before
  ANNOUNCEMENT was added to chk_notification_type.

  This script does not delete notification data.
*/

USE myfschool;

ALTER TABLE notification
  DROP CHECK chk_notification_type;

ALTER TABLE notification
  ADD CONSTRAINT chk_notification_type
  CHECK (type IN (
    'GRADE',
    'LEAVE',
    'ABSENCE',
    'TUITION',
    'CLUB',
    'ANNOUNCEMENT',
    'EVENT',
    'SYSTEM'
  ));

SHOW CREATE TABLE notification;
