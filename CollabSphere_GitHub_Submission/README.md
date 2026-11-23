# CollabSphere — Complete Backend/Database Project Package

CollabSphere is a student collaboration platform. This repository package organizes the backend/database documentation and the available 43-table SQL creation bundle.

## Included
- `docs/backend-architecture.md` — project aim, database domains, and scope
- `database/table-inventory.md` — inventory of the 43 recorded tables
- `database/sql/CollabSphere_43_Tables_Reconstructed.sql` — consolidated SQL creation script for all 43 tables
- `database/sql/README_reconstructed_sql.txt` — important SQL provenance and usage notes
- `normalization/normalization-report.md` — normalization concepts, current status, and evidence checklist
- `testing/testing-report.md` — test coverage and evidence register
- `evidence/README.md` — screenshots required to support the report
- `.gitignore` — excludes common secrets and local files

## Important accuracy and safety notes
1. The SQL file is **reconstructed**, not a verbatim export from the live TiDB database. Some table definitions were not preserved word-for-word in the conversation. Do not treat it as an authoritative backup or use it to overwrite an existing database.
2. `CREATE TABLE IF NOT EXISTS` does not update an already-existing table. The script is intended for careful review and a new/empty test database only.
3. The live schema should be exported from TiDB and compared with this reconstructed script before any reproducibility claim. Replace/add an authoritative `database/sql/schema.sql` only after exporting it from the actual database.
4. The normalization and testing documents are evidence templates/status summaries, not proof that every table passed 1NF/2NF/3NF/BCNF or every test passed.
5. Genuine screenshots and observed test outputs have not been fabricated. Add them under `evidence/` after running the tests.
6. This is the backend/database project package. It does not include a frontend or mobile application source code, because those were outside the agreed database-only scope.

## Suggested GitHub presentation order
1. Read this README.
2. Review `docs/backend-architecture.md`.
3. Review `database/table-inventory.md`.
4. Inspect the SQL bundle and its provenance note.
5. Review normalization and testing reports.
6. Add genuine evidence screenshots before final submission.
