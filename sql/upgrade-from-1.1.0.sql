-- Field Ledger 1.9.0 (pre-2.0) combined upgrade from 1.1.0 baseline
-- Includes: schema_version, sectors (1.4), crop_cycles (1.5)

CREATE TABLE IF NOT EXISTS schema_version (
  id TINYINT NOT NULL PRIMARY KEY DEFAULT 1,
  version VARCHAR(16) NOT NULL,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sectors (
  code        VARCHAR(8)   NOT NULL,
  label_en    VARCHAR(120) NOT NULL DEFAULT '',
  label_ar    VARCHAR(120) NOT NULL DEFAULT '',
  color       VARCHAR(16)  NOT NULL DEFAULT '#888888',
  sort_order  INT          NOT NULL DEFAULT 0,
  is_active   TINYINT(1)   NOT NULL DEFAULT 1,
  notes       TEXT         NULL,
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NULL,
  PRIMARY KEY (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO sectors (code, label_en, label_ar, color, sort_order, is_active) VALUES
  ('A', 'Block A', 'الكتلة A', '#91A8CC', 10, 1),
  ('B', 'Block B', 'الكتلة B', '#E8B394', 20, 1),
  ('C', 'Block C', 'الكتلة C', '#97C8A1', 30, 1),
  ('I', 'Irrigation / Greenhouse', 'قنوات الري / الصوب', '#B1A8CD', 40, 1);

INSERT IGNORE INTO sectors (code, label_en, label_ar, color, sort_order, is_active)
SELECT DISTINCT field_group,
       CONCAT('Block ', field_group),
       CONCAT('الكتلة ', field_group),
       '#888888', 100, 1
FROM fields
WHERE field_group IS NOT NULL AND field_group <> '';

CREATE TABLE IF NOT EXISTS crop_cycles (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  field_id     VARCHAR(8)    NOT NULL,
  crop_name    VARCHAR(120)  NOT NULL DEFAULT '',
  crop_icon    VARCHAR(16)   NOT NULL DEFAULT '',
  start_date   DATE          NULL,
  end_date     DATE          NULL,
  status       VARCHAR(16)   NOT NULL DEFAULT 'active',
  notes        TEXT          NULL,
  created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  closed_at    DATETIME      NULL,
  updated_at   DATETIME      NULL,
  INDEX (field_id),
  INDEX (status),
  INDEX (field_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET @col_exists := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'field_costs' AND COLUMN_NAME = 'cycle_id'
);
SET @sql := IF(@col_exists = 0,
  'ALTER TABLE field_costs ADD COLUMN cycle_id INT NULL DEFAULT NULL, ADD INDEX (cycle_id)',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

INSERT INTO crop_cycles (field_id, crop_name, crop_icon, start_date, end_date, status, notes, updated_at)
SELECT field_id, crop_name, crop_icon, crop_start, crop_end, 'active', NULLIF(notes, ''), updated_at
FROM fields f
WHERE crop_name <> ''
  AND NOT EXISTS (SELECT 1 FROM crop_cycles c WHERE c.field_id = f.field_id AND c.status = 'active');

INSERT INTO crop_cycles (field_id, crop_name, crop_icon, start_date, end_date, status, notes, updated_at)
SELECT field_id, next_crop_name, next_crop_icon, next_crop_start, NULL, 'planned', NULL, updated_at
FROM fields f
WHERE next_crop_name <> ''
  AND NOT EXISTS (SELECT 1 FROM crop_cycles c WHERE c.field_id = f.field_id AND c.status = 'planned');

UPDATE field_costs fc
INNER JOIN crop_cycles c ON c.field_id = fc.field_id AND c.status = 'active'
SET fc.cycle_id = c.id
WHERE fc.cycle_id IS NULL;

INSERT INTO schema_version (id, version) VALUES (1, '1.9.0')
  ON DUPLICATE KEY UPDATE version = '1.9.0';
