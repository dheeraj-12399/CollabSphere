# CollabSphere — Database Normalization Report

## Status
The project team has reported that normalization work is complete. Attach the actual schema and dependency analysis as evidence for formal review.

## Goals
- Reduce unnecessary duplication.
- Keep attributes dependent on the appropriate key.
- Prevent insertion, update, and deletion anomalies.
- Represent many-to-many relationships using association tables where appropriate.
- Preserve relationships with primary and foreign keys.

## Normal forms
### First Normal Form (1NF)
Each field contains one atomic value; avoid repeating groups and comma-separated collections.

### Second Normal Form (2NF)
The table is in 1NF and every non-key attribute depends on the whole candidate key, not just part of a composite key.

### Third Normal Form (3NF)
The table is in 2NF and non-key attributes do not depend transitively on a key through another non-key attribute.

## Examples of separated data domains
- `skills` + `user_skills`: skill catalogue separated from user-skill associations.
- `interests` + `user_interests`: interest catalogue separated from user selections.
- `project_tags` + `project_tag_mapping`: tag definitions separated from project-tag associations.
- `polls` + `poll_options` + `poll_votes`: poll questions, choices, and votes separated.
- `learning_paths` + `learning_path_steps`: paths separated from their ordered steps.

These examples illustrate the table organization; they do not by themselves prove every table is in 3NF or BCNF. Include functional dependencies and the approved schema to substantiate the normalization result.

## Evidence to attach
- Final table/column inventory.
- Functional-dependency notes for representative tables.
- ER diagram matching actual PK/FK constraints.
- Normalization checklist or reviewer sign-off.
