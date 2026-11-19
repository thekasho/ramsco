-- Rollback Field Ledger 2.1.0 foundation (keeps 2.0.0 ledger tables)
DROP TABLE IF EXISTS cost_allocations;
DROP TABLE IF EXISTS expense_lines;
DROP TABLE IF EXISTS expense_docs;
DROP TABLE IF EXISTS standard_cost_lines;
DROP TABLE IF EXISTS accounting_periods;
DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS cost_centers;
DROP TABLE IF EXISTS app_settings;

-- Optional: leave new columns on crop_cycles / fields / users / cost_categories
-- (dropping columns is destructive; do manually if required)

UPDATE schema_version SET version='2.0.0', updated_at=NOW() WHERE id=1;
