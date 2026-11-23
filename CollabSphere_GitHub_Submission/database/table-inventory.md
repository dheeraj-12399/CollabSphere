# CollabSphere Database — Complete Table Inventory

**Recorded table count: 43**

The descriptions below summarize each table's intended role. Confirm exact columns and constraints against the live schema export.

## Core user management

| No. | Table | Purpose |
|---:|---|---|
| 1 | `users` | Stores user/account records. |
| 2 | `profiles` | Stores user profile information. |
| 3 | `user_settings` | Stores user preferences. |
| 4 | `user_sessions` | Tracks user sessions. |

## Skills and interests

| No. | Table | Purpose |
|---:|---|---|
| 1 | `skills` | Master list of skills. |
| 2 | `user_skills` | Associates users with skills. |
| 3 | `interests` | Master list of interests. |
| 4 | `user_interests` | Associates users with interests. |

## Projects and collaboration

| No. | Table | Purpose |
|---:|---|---|
| 1 | `projects` | Stores collaborative projects. |
| 2 | `project_categories` | Classifies projects. |
| 3 | `project_members` | Stores project membership. |
| 4 | `project_tags` | Master list of project tags. |
| 5 | `project_tag_mapping` | Associates projects with tags. |
| 6 | `project_files` | Stores project file metadata. |
| 7 | `group_invitations` | Tracks group invitations. |
| 8 | `task_assignments` | Maps tasks to assigned participants. |

## Tasks and learning

| No. | Table | Purpose |
|---:|---|---|
| 1 | `tasks` | Stores project tasks. |
| 2 | `task_attachments` | Stores task attachment metadata. |
| 3 | `task_comments` | Stores task comments. |
| 4 | `learning_paths` | Stores structured learning paths. |
| 5 | `learning_path_steps` | Stores learning path steps. |
| 6 | `user_progress` | Tracks learning progress. |

## Study groups and communication

| No. | Table | Purpose |
|---:|---|---|
| 1 | `study_groups` | Stores study groups. |
| 2 | `study_group_members` | Stores group membership. |
| 3 | `conversations` | Stores conversation threads. |
| 4 | `conversation_members` | Maps users to conversations. |
| 5 | `messages` | Stores conversation messages. |
| 6 | `connections` | Tracks user connections. |
| 7 | `connection_blocks` | Tracks blocked-user relationships. |

## Discussions and engagement

| No. | Table | Purpose |
|---:|---|---|
| 1 | `discussions` | Stores discussion topics/posts. |
| 2 | `discussion_comments` | Stores discussion comments. |
| 3 | `discussion_likes` | Tracks discussion likes. |
| 4 | `polls` | Stores polls. |
| 5 | `poll_options` | Stores poll choices. |
| 6 | `poll_votes` | Stores submitted votes. |
| 7 | `group_resources` | Associates resources with groups. |

## Resources and announcements

| No. | Table | Purpose |
|---:|---|---|
| 1 | `resources` | Stores shared resources. |
| 2 | `resource_categories` | Classifies resources. |
| 3 | `resource_bookmarks` | Tracks bookmarked resources. |
| 4 | `announcements` | Stores announcements. |

## Notifications and system activity

| No. | Table | Purpose |
|---:|---|---|
| 1 | `notifications` | Stores user notifications. |
| 2 | `notification_preferences` | Stores notification preferences. |
| 3 | `activity_logs` | Records user/system activity. |

## Recorded database metrics

- Tables: **43**
- Foreign-key constraints: **69** (previously reported by the project team)
- Unique indexes excluding primary keys: **17** (previously reported)
- Primary keys: all 43 tables were reported to have one.

## Read-only table verification query

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'collabsphere'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

```sql
SELECT COUNT(*) AS total_tables
FROM information_schema.tables
WHERE table_schema = 'collabsphere'
  AND table_type = 'BASE TABLE';
```

Capture the actual query and result grid in `evidence/01-all-tables.png`.