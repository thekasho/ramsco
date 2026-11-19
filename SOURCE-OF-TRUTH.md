# Full source package

The complete **Ramsco Field Ledger 2.1.0** tree (all PHP/JS/CSS/SQL/map editor) is distributed as:

**`ramsco-2.1.0-base.zip`**

GitHub file-by-file upload from the automation channel is rate/size limited; use the zip as the canonical full tree.

## Extract over a clone

```bash
git clone https://github.com/thekasho/ramsco.git
cd ramsco
unzip -o /path/to/ramsco-2.1.0-base.zip
# contents land in field-ledger-2.0.1/ — move up if needed:
shopt -s dotglob
mv field-ledger-2.0.1/* .
rmdir field-ledger-2.0.1
git add -A
git commit -m "feat: full Field Ledger 2.1.0 base (map, costing, live editor)"
git push origin main
```

## Version

`VERSION` = **2.1.0**

Includes: map multi-select + double-click, live map-editor, standard costing API + admin UI, roles, upgrade SQL through 2.1.0.
