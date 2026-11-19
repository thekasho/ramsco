-- Rollback Field Ledger 2.0.0 financial ledger extras (keeps core field data)
-- Review before running on production.

DROP TABLE IF EXISTS field_income;
DROP TABLE IF EXISTS field_tag_map;
DROP TABLE IF EXISTS field_tags;
DROP TABLE IF EXISTS cost_categories;

UPDATE schema_version SET version='1.9.0', updated_at=NOW() WHERE id=1;
