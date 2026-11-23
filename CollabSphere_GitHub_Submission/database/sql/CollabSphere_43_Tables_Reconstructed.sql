USE `CollabSphere`;

-- CollabSphere: 43-table schema bundle
-- IMPORTANT:
-- This is a reconstructed, consolidated creation script based on the table
-- inventory and SQL designs available in the conversation. It is NOT a
-- verbatim export of the original 43 statements.
-- It does not DROP or ALTER existing tables.
-- Run only in a new/empty CollabSphere database, or review each statement first.
-- TiDB CHECK constraints may require tidb_enable_check_constraint=ON.

-- =========================================================
-- MODULE 01: USERS, PROFILES AND SKILLS (TABLES 1-8)
-- =========================================================

-- TABLE 1: users
CREATE TABLE IF NOT EXISTS users (
    user_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    account_status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_users_status CHECK (account_status IN ('active','inactive','suspended'))
) ENGINE=InnoDB;

-- TABLE 2: profiles
CREATE TABLE IF NOT EXISTS profiles (
    profile_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    college_name VARCHAR(200) NULL,
    department VARCHAR(150) NULL,
    academic_year VARCHAR(30) NULL,
    bio TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_profiles_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- TABLE 3: user_settings
CREATE TABLE IF NOT EXISTS user_settings (
    setting_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL UNIQUE,
    theme VARCHAR(20) NOT NULL DEFAULT 'system',
    email_notifications BOOLEAN NOT NULL DEFAULT TRUE,
    push_notifications BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_user_settings_theme CHECK (theme IN ('light','dark','system')),
    CONSTRAINT fk_user_settings_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- TABLE 4: user_sessions
CREATE TABLE IF NOT EXISTS user_sessions (
    session_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    session_status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    revoked_at TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_user_sessions_status CHECK (session_status IN ('active','expired','revoked')),
    CONSTRAINT fk_user_sessions_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_user_sessions_user (user_id),
    INDEX idx_user_sessions_expires (expires_at)
) ENGINE=InnoDB;

-- TABLE 5: skills
CREATE TABLE IF NOT EXISTS skills (
    skill_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    skill_name VARCHAR(120) NOT NULL UNIQUE,
    description TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- TABLE 6: user_skills
CREATE TABLE IF NOT EXISTS user_skills (
    user_id BIGINT UNSIGNED NOT NULL,
    skill_id BIGINT UNSIGNED NOT NULL,
    proficiency_level VARCHAR(30) NOT NULL DEFAULT 'beginner',
    added_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, skill_id),
    CONSTRAINT chk_user_skills_level CHECK (proficiency_level IN ('beginner','intermediate','advanced','expert')),
    CONSTRAINT fk_user_skills_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_user_skills_skill FOREIGN KEY (skill_id)
        REFERENCES skills(skill_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_user_skills_skill (skill_id)
) ENGINE=InnoDB;

-- TABLE 7: interests
CREATE TABLE IF NOT EXISTS interests (
    interest_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    interest_name VARCHAR(120) NOT NULL UNIQUE,
    description TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- TABLE 8: user_interests
CREATE TABLE IF NOT EXISTS user_interests (
    user_id BIGINT UNSIGNED NOT NULL,
    interest_id BIGINT UNSIGNED NOT NULL,
    added_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, interest_id),
    CONSTRAINT fk_user_interests_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_user_interests_interest FOREIGN KEY (interest_id)
        REFERENCES interests(interest_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_user_interests_interest (interest_id)
) ENGINE=InnoDB;

-- =========================================================
-- MODULE 02: PROJECT MANAGEMENT (TABLES 9-14)
-- =========================================================

-- TABLE 9: project_categories
CREATE TABLE IF NOT EXISTS project_categories (
    category_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(120) NOT NULL UNIQUE,
    description TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- TABLE 10: projects
CREATE TABLE IF NOT EXISTS projects (
    project_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_id BIGINT UNSIGNED NOT NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    project_title VARCHAR(200) NOT NULL,
    description TEXT NULL,
    visibility VARCHAR(20) NOT NULL DEFAULT 'public',
    project_status VARCHAR(30) NOT NULL DEFAULT 'planning',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_projects_visibility CHECK (visibility IN ('public','private')),
    CONSTRAINT chk_projects_status CHECK (project_status IN ('planning','in_progress','completed','on_hold','cancelled')),
    CONSTRAINT fk_projects_category FOREIGN KEY (category_id)
        REFERENCES project_categories(category_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_projects_creator FOREIGN KEY (created_by)
        REFERENCES users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_projects_category (category_id),
    INDEX idx_projects_creator (created_by),
    INDEX idx_projects_visibility (visibility),
    INDEX idx_projects_status (project_status)
) ENGINE=InnoDB;

-- TABLE 11: project_members
CREATE TABLE IF NOT EXISTS project_members (
    project_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'member',
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    membership_status VARCHAR(20) NOT NULL DEFAULT 'active',
    PRIMARY KEY (project_id, user_id),
    CONSTRAINT chk_project_members_role CHECK (role IN ('owner','member')),
    CONSTRAINT chk_project_members_status CHECK (membership_status IN ('active','inactive','removed')),
    CONSTRAINT fk_project_members_project FOREIGN KEY (project_id)
        REFERENCES projects(project_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_project_members_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_project_members_user (user_id)
) ENGINE=InnoDB;

-- TABLE 12: project_files
CREATE TABLE IF NOT EXISTS project_files (
    file_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    project_id BIGINT UNSIGNED NOT NULL,
    uploaded_by BIGINT UNSIGNED NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_url VARCHAR(2048) NOT NULL,
    file_type VARCHAR(80) NULL,
    file_size_bytes BIGINT UNSIGNED NULL,
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_project_files_project FOREIGN KEY (project_id)
        REFERENCES projects(project_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_project_files_uploader FOREIGN KEY (uploaded_by)
        REFERENCES users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_project_files_project (project_id),
    INDEX idx_project_files_uploader (uploaded_by)
) ENGINE=InnoDB;

-- TABLE 13: project_tags
CREATE TABLE IF NOT EXISTS project_tags (
    tag_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tag_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- TABLE 14: project_tag_mapping
CREATE TABLE IF NOT EXISTS project_tag_mapping (
    project_id BIGINT UNSIGNED NOT NULL,
    tag_id BIGINT UNSIGNED NOT NULL,
    assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (project_id, tag_id),
    CONSTRAINT fk_project_tag_mapping_project FOREIGN KEY (project_id)
        REFERENCES projects(project_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_project_tag_mapping_tag FOREIGN KEY (tag_id)
        REFERENCES project_tags(tag_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_project_tag_mapping_tag (tag_id)
) ENGINE=InnoDB;

-- =========================================================
-- MODULE 03: TASK MANAGEMENT (TABLES 15-18)
-- =========================================================

-- TABLE 15: tasks
CREATE TABLE IF NOT EXISTS tasks (
    task_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    project_id BIGINT UNSIGNED NOT NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    task_title VARCHAR(200) NOT NULL,
    description TEXT NULL,
    task_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    priority VARCHAR(20) NOT NULL DEFAULT 'medium',
    due_date DATETIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_tasks_status CHECK (task_status IN ('pending','in_progress','completed','blocked','cancelled')),
    CONSTRAINT chk_tasks_priority CHECK (priority IN ('low','medium','high','urgent')),
    CONSTRAINT fk_tasks_project FOREIGN KEY (project_id)
        REFERENCES projects(project_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_tasks_creator FOREIGN KEY (created_by)
        REFERENCES users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_tasks_project (project_id),
    INDEX idx_tasks_creator (created_by),
    INDEX idx_tasks_status (task_status),
    INDEX idx_tasks_due_date (due_date)
) ENGINE=InnoDB;

-- TABLE 16: task_assignments
CREATE TABLE IF NOT EXISTS task_assignments (
    task_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    assigned_by BIGINT UNSIGNED NOT NULL,
    assignment_status VARCHAR(20) NOT NULL DEFAULT 'assigned',
    assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (task_id, user_id),
    CONSTRAINT chk_task_assignments_status CHECK (assignment_status IN ('assigned','accepted','in_progress','completed','rejected')),
    CONSTRAINT fk_task_assignments_task FOREIGN KEY (task_id)
        REFERENCES tasks(task_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_task_assignments_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_task_assignments_assigner FOREIGN KEY (assigned_by)
        REFERENCES users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_task_assignments_user (user_id),
    INDEX idx_task_assignments_assigner (assigned_by)
) ENGINE=InnoDB;

-- TABLE 17: task_comments
CREATE TABLE IF NOT EXISTS task_comments (
    comment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    task_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_task_comments_task FOREIGN KEY (task_id)
        REFERENCES tasks(task_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_task_comments_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_task_comments_task (task_id),
    INDEX idx_task_comments_user (user_id),
    INDEX idx_task_comments_created (created_at)
) ENGINE=InnoDB;

-- TABLE 18: task_attachments
CREATE TABLE IF NOT EXISTS task_attachments (
    attachment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    task_id BIGINT UNSIGNED NOT NULL,
    uploaded_by BIGINT UNSIGNED NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_url VARCHAR(2048) NOT NULL,
    file_type VARCHAR(80) NULL,
    file_size_bytes BIGINT UNSIGNED NULL,
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_task_attachments_task FOREIGN KEY (task_id)
        REFERENCES tasks(task_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_task_attachments_uploader FOREIGN KEY (uploaded_by)
        REFERENCES users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_task_attachments_task (task_id),
    INDEX idx_task_attachments_uploader (uploaded_by)
) ENGINE=InnoDB;

-- =========================================================
-- MODULE 04: STUDY GROUPS (TABLES 19-22)
-- =========================================================

-- TABLE 19: study_groups
CREATE TABLE IF NOT EXISTS study_groups (
    group_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    created_by BIGINT UNSIGNED NOT NULL,
    group_name VARCHAR(200) NOT NULL,
    description TEXT NULL,
    group_visibility VARCHAR(20) NOT NULL DEFAULT 'public',
    group_status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_group_visibility CHECK (group_visibility IN ('public','private')),
    CONSTRAINT chk_group_status CHECK (group_status IN ('active','inactive','archived')),
    CONSTRAINT fk_study_groups_creator FOREIGN KEY (created_by)
        REFERENCES users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_study_groups_creator (created_by),
    INDEX idx_study_groups_visibility (group_visibility)
) ENGINE=InnoDB;

-- TABLE 20: study_group_members
CREATE TABLE IF NOT EXISTS study_group_members (
    group_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    member_role VARCHAR(20) NOT NULL DEFAULT 'member',
    membership_status VARCHAR(20) NOT NULL DEFAULT 'active',
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (group_id, user_id),
    CONSTRAINT chk_group_member_role CHECK (member_role IN ('owner','moderator','member')),
    CONSTRAINT chk_group_membership_status CHECK (membership_status IN ('active','inactive','removed')),
    CONSTRAINT fk_group_members_group FOREIGN KEY (group_id)
        REFERENCES study_groups(group_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_group_members_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_group_members_user (user_id)
) ENGINE=InnoDB;

-- TABLE 21: group_invitations
CREATE TABLE IF NOT EXISTS group_invitations (
    invitation_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    group_id BIGINT UNSIGNED NOT NULL,
    invited_by BIGINT UNSIGNED NOT NULL,
    invited_user_id BIGINT UNSIGNED NOT NULL,
    invitation_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    invited_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_group_invitation_status CHECK (invitation_status IN ('pending','accepted','declined','cancelled')),
    CONSTRAINT fk_group_invitation_group FOREIGN KEY (group_id)
        REFERENCES study_groups(group_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_group_invitation_sender FOREIGN KEY (invited_by)
        REFERENCES users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_group_invitation_receiver FOREIGN KEY (invited_user_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_group_invitations_group (group_id),
    INDEX idx_group_invitations_receiver (invited_user_id),
    INDEX idx_group_invitations_status (invitation_status)
) ENGINE=InnoDB;

-- TABLE 22: group_resources
CREATE TABLE IF NOT EXISTS group_resources (
    group_resource_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    group_id BIGINT UNSIGNED NOT NULL,
    uploaded_by BIGINT UNSIGNED NOT NULL,
    resource_title VARCHAR(200) NOT NULL,
    resource_description TEXT NULL,
    resource_url VARCHAR(2048) NOT NULL,
    resource_type VARCHAR(30) NOT NULL,
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_group_resources_group FOREIGN KEY (group_id)
        REFERENCES study_groups(group_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_group_resources_uploader FOREIGN KEY (uploaded_by)
        REFERENCES users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_group_resources_group (group_id),
    INDEX idx_group_resources_uploader (uploaded_by)
) ENGINE=InnoDB;

-- =========================================================
-- MODULE 05: DISCUSSIONS AND ANNOUNCEMENTS (TABLES 23-26)
-- =========================================================

-- TABLE 23: discussions
CREATE TABLE IF NOT EXISTS discussions (
    discussion_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    author_id BIGINT UNSIGNED NOT NULL,
    project_id BIGINT UNSIGNED NULL,
    group_id BIGINT UNSIGNED NULL,
    discussion_title VARCHAR(200) NOT NULL,
    discussion_content TEXT NOT NULL,
    discussion_visibility VARCHAR(20) NOT NULL DEFAULT 'public',
    discussion_status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_discussion_visibility CHECK (discussion_visibility IN ('public','project','group','both')),
    CONSTRAINT chk_discussion_status CHECK (discussion_status IN ('active','edited','closed','deleted')),
    CONSTRAINT fk_discussions_author FOREIGN KEY (author_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_discussions_project FOREIGN KEY (project_id)
        REFERENCES projects(project_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_discussions_group FOREIGN KEY (group_id)
        REFERENCES study_groups(group_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_discussions_author (author_id),
    INDEX idx_discussions_project (project_id),
    INDEX idx_discussions_group (group_id),
    INDEX idx_discussions_visibility (discussion_visibility),
    INDEX idx_discussions_created (created_at)
) ENGINE=InnoDB;

-- TABLE 24: discussion_comments
CREATE TABLE IF NOT EXISTS discussion_comments (
    comment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    discussion_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    parent_comment_id BIGINT UNSIGNED NULL,
    comment_content TEXT NOT NULL,
    comment_status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_discussion_comment_status CHECK (comment_status IN ('active','edited','deleted')),
    CONSTRAINT fk_discussion_comments_discussion FOREIGN KEY (discussion_id)
        REFERENCES discussions(discussion_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_discussion_comments_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_discussion_comments_parent FOREIGN KEY (parent_comment_id)
        REFERENCES discussion_comments(comment_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_discussion_comments_discussion (discussion_id),
    INDEX idx_discussion_comments_user (user_id),
    INDEX idx_discussion_comments_parent (parent_comment_id)
) ENGINE=InnoDB;

-- TABLE 25: discussion_likes
CREATE TABLE IF NOT EXISTS discussion_likes (
    discussion_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    liked_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (discussion_id, user_id),
    CONSTRAINT fk_discussion_likes_discussion FOREIGN KEY (discussion_id)
        REFERENCES discussions(discussion_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_discussion_likes_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_discussion_likes_user (user_id)
) ENGINE=InnoDB;

-- TABLE 26: announcements
CREATE TABLE IF NOT EXISTS announcements (
    announcement_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    author_id BIGINT UNSIGNED NOT NULL,
    project_id BIGINT UNSIGNED NULL,
    group_id BIGINT UNSIGNED NULL,
    announcement_title VARCHAR(200) NOT NULL,
    announcement_content TEXT NOT NULL,
    announcement_visibility VARCHAR(20) NOT NULL DEFAULT 'public',
    announcement_status VARCHAR(20) NOT NULL DEFAULT 'published',
    published_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_announcement_visibility CHECK (announcement_visibility IN ('public','project','group','both')),
    CONSTRAINT chk_announcement_status CHECK (announcement_status IN ('draft','published','archived')),
    CONSTRAINT fk_announcements_author FOREIGN KEY (author_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_announcements_project FOREIGN KEY (project_id)
        REFERENCES projects(project_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_announcements_group FOREIGN KEY (group_id)
        REFERENCES study_groups(group_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_announcements_author (author_id),
    INDEX idx_announcements_project (project_id),
    INDEX idx_announcements_group (group_id),
    INDEX idx_announcements_status (announcement_status),
    INDEX idx_announcements_published (published_at)
) ENGINE=InnoDB;

-- =========================================================
-- MODULE 06: POLLS AND VOTING (TABLES 27-29)
-- =========================================================

-- TABLE 27: polls
CREATE TABLE IF NOT EXISTS polls (
    poll_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    created_by BIGINT UNSIGNED NOT NULL,
    group_id BIGINT UNSIGNED NULL,
    project_id BIGINT UNSIGNED NULL,
    poll_question VARCHAR(500) NOT NULL,
    poll_description TEXT NULL,
    poll_status VARCHAR(20) NOT NULL DEFAULT 'active',
    allows_multiple_choices BOOLEAN NOT NULL DEFAULT FALSE,
    starts_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ends_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_poll_status CHECK (poll_status IN ('draft','active','closed','cancelled')),
    CONSTRAINT fk_polls_creator FOREIGN KEY (created_by)
        REFERENCES users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_polls_group FOREIGN KEY (group_id)
        REFERENCES study_groups(group_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_polls_project FOREIGN KEY (project_id)
        REFERENCES projects(project_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_polls_creator (created_by),
    INDEX idx_polls_group (group_id),
    INDEX idx_polls_project (project_id),
    INDEX idx_polls_status (poll_status)
) ENGINE=InnoDB;

-- TABLE 28: poll_options
CREATE TABLE IF NOT EXISTS poll_options (
    option_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    poll_id BIGINT UNSIGNED NOT NULL,
    option_text VARCHAR(300) NOT NULL,
    display_order INT UNSIGNED NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_poll_options_poll FOREIGN KEY (poll_id)
        REFERENCES polls(poll_id) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY uq_poll_options_poll_option (poll_id, option_id),
    UNIQUE KEY uq_poll_options_poll_text (poll_id, option_text),
    INDEX idx_poll_options_poll_order (poll_id, display_order)
) ENGINE=InnoDB;

-- TABLE 29: poll_votes
CREATE TABLE IF NOT EXISTS poll_votes (
    poll_id BIGINT UNSIGNED NOT NULL,
    option_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    voted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (poll_id, user_id),
    CONSTRAINT fk_poll_votes_option FOREIGN KEY (poll_id, option_id)
        REFERENCES poll_options(poll_id, option_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_poll_votes_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_poll_votes_option (poll_id, option_id),
    INDEX idx_poll_votes_user (user_id)
) ENGINE=InnoDB;

-- =========================================================
-- MODULE 07: CONNECTIONS AND NOTIFICATIONS (TABLES 30-33)
-- =========================================================

-- TABLE 30: connections
CREATE TABLE IF NOT EXISTS connections (
    connection_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    requester_id BIGINT UNSIGNED NOT NULL,
    receiver_id BIGINT UNSIGNED NOT NULL,
    connection_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    requested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_connections_status CHECK (connection_status IN ('pending','accepted','declined','cancelled')),
    CONSTRAINT chk_connections_not_self CHECK (requester_id <> receiver_id),
    CONSTRAINT fk_connections_requester FOREIGN KEY (requester_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_connections_receiver FOREIGN KEY (receiver_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_connections_requester (requester_id),
    INDEX idx_connections_receiver (receiver_id),
    INDEX idx_connections_status (connection_status)
) ENGINE=InnoDB;

-- TABLE 31: connection_blocks
CREATE TABLE IF NOT EXISTS connection_blocks (
    blocker_id BIGINT UNSIGNED NOT NULL,
    blocked_user_id BIGINT UNSIGNED NOT NULL,
    blocked_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (blocker_id, blocked_user_id),
    CONSTRAINT chk_connection_blocks_not_self CHECK (blocker_id <> blocked_user_id),
    CONSTRAINT fk_connection_blocks_blocker FOREIGN KEY (blocker_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_connection_blocks_blocked FOREIGN KEY (blocked_user_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- TABLE 32: notifications
CREATE TABLE IF NOT EXISTS notifications (
    notification_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    notification_type VARCHAR(60) NOT NULL,
    notification_title VARCHAR(200) NOT NULL,
    notification_message TEXT NOT NULL,
    related_entity_type VARCHAR(60) NULL,
    related_entity_id BIGINT UNSIGNED NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_notifications_user (user_id),
    INDEX idx_notifications_user_read (user_id, is_read),
    INDEX idx_notifications_created (created_at)
) ENGINE=InnoDB;

-- TABLE 33: notification_preferences
CREATE TABLE IF NOT EXISTS notification_preferences (
    preference_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    notification_type VARCHAR(60) NOT NULL,
    email_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    push_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    in_app_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_notification_preferences_user_type (user_id, notification_type),
    CONSTRAINT fk_notification_preferences_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_notification_preferences_user (user_id)
) ENGINE=InnoDB;

-- =========================================================
-- MODULE 08: MESSAGING (TABLES 34-36)
-- =========================================================

-- TABLE 34: conversations
CREATE TABLE IF NOT EXISTS conversations (
    conversation_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    created_by BIGINT UNSIGNED NOT NULL,
    conversation_type VARCHAR(20) NOT NULL DEFAULT 'direct',
    conversation_title VARCHAR(200) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_conversations_type CHECK (conversation_type IN ('direct','group')),
    CONSTRAINT fk_conversations_creator FOREIGN KEY (created_by)
        REFERENCES users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_conversations_creator (created_by)
) ENGINE=InnoDB;

-- TABLE 35: conversation_members
CREATE TABLE IF NOT EXISTS conversation_members (
    conversation_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    member_role VARCHAR(20) NOT NULL DEFAULT 'member',
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_read_at TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (conversation_id, user_id),
    CONSTRAINT chk_conversation_members_role CHECK (member_role IN ('admin','member')),
    CONSTRAINT fk_conversation_members_conversation FOREIGN KEY (conversation_id)
        REFERENCES conversations(conversation_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_conversation_members_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_conversation_members_user (user_id)
) ENGINE=InnoDB;

-- TABLE 36: messages
CREATE TABLE IF NOT EXISTS messages (
    message_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    conversation_id BIGINT UNSIGNED NOT NULL,
    sender_id BIGINT UNSIGNED NOT NULL,
    message_content TEXT NOT NULL,
    message_type VARCHAR(20) NOT NULL DEFAULT 'text',
    sent_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    edited_at TIMESTAMP NULL DEFAULT NULL,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_messages_type CHECK (message_type IN ('text','file','system')),
    CONSTRAINT fk_messages_conversation FOREIGN KEY (conversation_id)
        REFERENCES conversations(conversation_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_messages_sender FOREIGN KEY (sender_id)
        REFERENCES users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_messages_conversation_time (conversation_id, sent_at),
    INDEX idx_messages_sender (sender_id)
) ENGINE=InnoDB;

-- =========================================================
-- MODULE 09: SHARED RESOURCES (TABLES 37-39)
-- =========================================================

-- TABLE 37: resource_categories
CREATE TABLE IF NOT EXISTS resource_categories (
    resource_category_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(120) NOT NULL UNIQUE,
    description TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- TABLE 38: resources
CREATE TABLE IF NOT EXISTS resources (
    resource_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    uploaded_by BIGINT UNSIGNED NOT NULL,
    resource_category_id BIGINT UNSIGNED NULL,
    resource_title VARCHAR(200) NOT NULL,
    resource_description TEXT NULL,
    resource_url VARCHAR(2048) NOT NULL,
    resource_type VARCHAR(40) NOT NULL,
    visibility VARCHAR(20) NOT NULL DEFAULT 'public',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_resources_visibility CHECK (visibility IN ('public','private')),
    CONSTRAINT fk_resources_uploader FOREIGN KEY (uploaded_by)
        REFERENCES users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_resources_category FOREIGN KEY (resource_category_id)
        REFERENCES resource_categories(resource_category_id) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_resources_uploader (uploaded_by),
    INDEX idx_resources_category (resource_category_id),
    INDEX idx_resources_visibility (visibility)
) ENGINE=InnoDB;

-- TABLE 39: resource_bookmarks
CREATE TABLE IF NOT EXISTS resource_bookmarks (
    user_id BIGINT UNSIGNED NOT NULL,
    resource_id BIGINT UNSIGNED NOT NULL,
    bookmarked_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, resource_id),
    CONSTRAINT fk_resource_bookmarks_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_resource_bookmarks_resource FOREIGN KEY (resource_id)
        REFERENCES resources(resource_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_resource_bookmarks_resource (resource_id)
) ENGINE=InnoDB;

-- =========================================================
-- MODULE 10: LEARNING PATHS AND ACTIVITY (TABLES 40-43)
-- =========================================================

-- TABLE 40: learning_paths
CREATE TABLE IF NOT EXISTS learning_paths (
    learning_path_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    created_by BIGINT UNSIGNED NOT NULL,
    path_title VARCHAR(200) NOT NULL,
    path_description TEXT NULL,
    difficulty_level VARCHAR(30) NOT NULL DEFAULT 'beginner',
    path_status VARCHAR(20) NOT NULL DEFAULT 'published',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_learning_paths_difficulty CHECK (difficulty_level IN ('beginner','intermediate','advanced')),
    CONSTRAINT chk_learning_paths_status CHECK (path_status IN ('draft','published','archived')),
    CONSTRAINT fk_learning_paths_creator FOREIGN KEY (created_by)
        REFERENCES users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_learning_paths_creator (created_by),
    INDEX idx_learning_paths_status (path_status)
) ENGINE=InnoDB;

-- TABLE 41: learning_path_steps
CREATE TABLE IF NOT EXISTS learning_path_steps (
    step_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    learning_path_id BIGINT UNSIGNED NOT NULL,
    step_number INT UNSIGNED NOT NULL,
    step_title VARCHAR(200) NOT NULL,
    step_description TEXT NULL,
    resource_url VARCHAR(2048) NULL,
    estimated_minutes INT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_learning_path_steps_path FOREIGN KEY (learning_path_id)
        REFERENCES learning_paths(learning_path_id) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY uq_learning_path_step_number (learning_path_id, step_number),
    INDEX idx_learning_path_steps_path (learning_path_id)
) ENGINE=InnoDB;

-- TABLE 42: user_progress
CREATE TABLE IF NOT EXISTS user_progress (
    progress_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    learning_path_id BIGINT UNSIGNED NOT NULL,
    step_id BIGINT UNSIGNED NULL,
    progress_status VARCHAR(20) NOT NULL DEFAULT 'not_started',
    completion_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    started_at TIMESTAMP NULL DEFAULT NULL,
    completed_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_user_progress_status CHECK (progress_status IN ('not_started','in_progress','completed')),
    CONSTRAINT chk_user_progress_percentage CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
    CONSTRAINT fk_user_progress_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_user_progress_path FOREIGN KEY (learning_path_id)
        REFERENCES learning_paths(learning_path_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_user_progress_step FOREIGN KEY (step_id)
        REFERENCES learning_path_steps(step_id) ON DELETE SET NULL ON UPDATE CASCADE,
    UNIQUE KEY uq_user_progress_user_path (user_id, learning_path_id),
    INDEX idx_user_progress_path (learning_path_id)
) ENGINE=InnoDB;

-- TABLE 43: activity_logs
CREATE TABLE IF NOT EXISTS activity_logs (
    activity_log_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NULL,
    activity_type VARCHAR(80) NOT NULL,
    entity_type VARCHAR(80) NULL,
    entity_id BIGINT UNSIGNED NULL,
    activity_description TEXT NULL,
    ip_address VARCHAR(45) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_activity_logs_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_activity_logs_user (user_id),
    INDEX idx_activity_logs_type (activity_type),
    INDEX idx_activity_logs_created (created_at),
    INDEX idx_activity_logs_entity (entity_type, entity_id)
) ENGINE=InnoDB;

-- END OF 43-TABLE SCRIPT
