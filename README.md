# Ramsco — Field Ledger

Farm field map, crop cycles, financial ledger, and **standard costing** (2.1).

**Live:** https://ramsco.gt.tc/

## Stack
- PHP + MySQL
- SVG map from `public/map-definition.json`
- Admin panel: fields, sectors, cycles, ledger, tags, standard costing
- Live map editor: `public/map-editor.html` → saves via `api/map-definition.php`

## Deploy
1. Copy `public/` to web root (or point vhost at `public/`)
2. Copy `backend/` next to `public/` (sibling)
3. Copy `backend/config.example.php` → `backend/config.php` and set DB credentials
4. Import SQL: `sql/upgrade-from-1.1.0.sql` then `sql/upgrade-to-2.0.0.sql` then `sql/upgrade-to-2.1.0.sql` (or full schema as needed)
5. Open `setup.php` once if users table is empty

## Version
See `VERSION` — **2.1.0** base (map multi-select, live editor, costing API + UI).

## License
Private project for Ramsco farm operations.
