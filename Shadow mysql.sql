CREATE TABLE `users` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `tel_contact` varchar(255) UNIQUE NOT NULL,
  `email_address` varchar(255) UNIQUE,
  `username` varchar(30),
  `mode` ENUM ('casual', 'stealth'),
  `bio` varchar(255),
  `verified` bool NOT NULL DEFAULT false,
  `has_profile_photo` bool NOT NULL DEFAULT false,
  `last_seen` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `updated_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `created_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE `verifications` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `user_id` binary(16) NOT NULL,
  `secret_code` integer(6) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE `profile_photo` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `updated_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `name` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `user_id` binary(16) NOT NULL
);

CREATE TABLE `chats` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `title` varchar(255) NOT NULL,
  `last_message` text,
  `type` ENUM ('private', 'group', 'ghost') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `updated_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `created_by` binary(16) NOT NULL
);

CREATE TABLE `chat_participants` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `created_at` timestamp NOT NULL,
  `role` ENUM ('member', 'admin', 'super_admin') NOT NULL,
  `user_id` binary(16) NOT NULL,
  `chat_id` binary(16) NOT NULL
);

CREATE TABLE `messages` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `updated_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `content` text NOT NULL,
  `sender` binary(16) NOT NULL,
  `receiver` binary(16) NOT NULL,
  `format` ENUM ('view_once', 'ordinary', 'recallable') NOT NULL COMMENT 'Either, view once or recallable or ordinary format',
  `type` ENUM ('media', 'text', 'attachment') NOT NULL,
  `scheduled` bool NOT NULL DEFAULT false,
  `visibility` ENUM ('all', 'selected', 'except_selected') NOT NULL COMMENT 'The category of people to whom the message shall be sent',
  `visibility_set` binary(16) COMMENT 'Specifies the set of user to whom should the message be sent or not sent for group chats',
  `status` ENUM ('sent', 'delivered', 'read') NOT NULL,
  `reply_to` ENUM ('none', 'status', 'message') NOT NULL DEFAULT 'none' COMMENT 'Specifies whether it''s a standalone msg or a reply to status update or message',
  `target_id` binary(16) COMMENT 'A reference to the message_id/status_id being replied to'
);

CREATE TABLE `message_media` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `name` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `type` ENUM ('document', 'video', 'photo', 'audio') NOT NULL COMMENT 'Either document or video or photo or audio',
  `message_id` binary(16) NOT NULL
);

CREATE TABLE `message_recalls` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `message_id` binary(16) NOT NULL,
  `recall_at` timestamp DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE `message_schedules` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `dispatch_at` timestamp NOT NULL COMMENT 'Next time when message will be sent',
  `frequency` ENUM ('none', 'hourly', 'daily', 'weekly', 'monthly', 'yearly') NOT NULL COMMENT 'Defines the message should be sent after every n days for daily, weeks for weekly, ...',
  `interval_value` smallint NOT NULL COMMENT 'The `n` value for the wait defined by interval',
  `message_id` binary(16) UNIQUE NOT NULL
);

CREATE TABLE `read_receipts` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `message_id` binary(16),
  `user_id` binary(16),
  `created_at` timestamp NOT NULL,
  `deliver_time` timestamp NOT NULL,
  `read_time` timestamp
);

CREATE TABLE `auto_responses` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `trigger` varchar(255) NOT NULL COMMENT 'The matched key word to execute an auto response',
  `response` text NOT NULL,
  `user_id` binary(16) NOT NULL
);

CREATE TABLE `message_visibility_sets` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `created_at` timestamp DEFAULT (CURRENT_TIMESTAMP),
  `updated_at` timestamp DEFAULT (CURRENT_TIMESTAMP),
  `name` varchar(255)
);

CREATE TABLE `message_visibility_set_members` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `user_id` binary(16) NOT NULL,
  `set_id` binary(16) NOT NULL
);

CREATE TABLE `articles` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `title` varchar(255) NOT NULL,
  `status` ENUM ('draft', 'published', 'archived') NOT NULL COMMENT 'Whether saved as a draft, or published or an archive',
  `content` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `updated_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `published_at` timestamp DEFAULT (CURRENT_TIMESTAMP),
  `category` varchar9(25) NOT NULL,
  `author` binary(16) NOT NULL,
  `visibility` ENUM ('all', 'contacts', 'selected', 'except_selected') NOT NULL COMMENT 'Can either be all users on systen or contacts or selected users or except_selected to have the article as part of their feed',
  `visibility_set` binary(16)
);

CREATE TABLE `article_tags` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `value` varchar(15),
  `article` binary(16) NOT NULL
);

CREATE TABLE `article_visibility_sets` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `updated_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `name` varchar(255) NOT NULL
);

CREATE TABLE `article_visibility_set_members` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `user_id` binary(16) NOT NULL,
  `set_id` binary(16) NOT NULL
);

CREATE TABLE `article_interactions` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `type` ENUM ('reaction', 'comment', 'bookmark') NOT NULL COMMENT 'Can either be a reaction or a comment or bo',
  `created_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `value` varchar(255) NOT NULL,
  `article_id` binary(16) NOT NULL,
  `user_id` binary(16) NOT NULL
);

CREATE TABLE `article_views` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `user_id` binary(16) NOT NULL,
  `article_id` binary(16) NOT NULL
);

CREATE TABLE `article_bookmarks` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT 'CURRENT_TIMESTAMP',
  `article_id` binary(16) NOT NULL,
  `user_id` binary(16) NOT NULL
);

CREATE TABLE `calls` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `type` ENUM ('video', 'voice') NOT NULL,
  `ended_at` timestamp,
  `started_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `status` ENUM ('missed', 'ended', 'calling', 'ringing', 'ongoing', 'rejected') NOT NULL DEFAULT 'calling',
  `talk_time` integer DEFAULT 0 COMMENT 'Stored as milli_seconds',
  `caller` binary(16) NOT NULL,
  `callee` binary(16) NOT NULL
);

CREATE TABLE `call_participants` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `call_id` binary(16) NOT NULL,
  `user_id` binary(16) NOT NULL,
  `join_time` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `leave_time` timestamp,
  `role` ENUM ('initator', 'moderator', 'ordinary', 'speaker') NOT NULL
);

CREATE TABLE `status_updates` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `expires_at` timestamp NOT NULL,
  `format` ENUM ('link', 'text', 'attachment', 'media') NOT NULL,
  `content` varchar(255) NOT NULL,
  `visibility` ENUM ('contacts', 'selected', 'except_selected') NOT NULL,
  `visibility_set` binary(16) NOT NULL DEFAULT 'contacts',
  `expiry_time` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE `status_visibility_set` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `updated_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `name` varchar(255) NOT NULL
);

CREATE TABLE `status_visbility_set_members` (
  `id` binary(16) NOT NULL,
  `created_at` timestamp NOT NULL,
  `user_id` binary(16) NOT NULL,
  `set_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`, `created_at`)
);

CREATE TABLE `status_views` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `user_id` bianry(16) NOT NULL,
  `status_id` binary(16) NOT NULL
);

CREATE TABLE `status_replies` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `user_id` binary(16) NOT NULL COMMENT 'The user replying to the subject status',
  `chat_id` binary(16) NOT NULL COMMENT 'The chat to which the reply targets',
  `status_id` binary(16) NOT NULL COMMENT 'The status being replied to',
  `content` text NOT NULL COMMENT 'Body of the reply',
  `created_at` timestamp
);

CREATE TABLE `status_media` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  `name` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `type` ENUM ('document', 'video', 'photo', 'audio'),
  `status_id` binary(16) NOT NULL
);

CREATE TABLE `status_schedules` (
  `id` binary(16) PRIMARY KEY NOT NULL,
  `dispatch_at` timestamp NOT NULL,
  `frequency` ENUM ('none', 'hourly', 'daily', 'weekly', 'monthly', 'yearly'),
  `interval_value` smallint,
  `status_id` binary(16) UNIQUE NOT NULL
);

CREATE UNIQUE INDEX `chat_participants_index_0` ON `chat_participants` (`chat_id`, `user_id`);

CREATE UNIQUE INDEX `read_receipts_index_1` ON `read_receipts` (`message_id`, `user_id`);

CREATE UNIQUE INDEX `message_visibility_set_members_index_2` ON `message_visibility_set_members` (`set_id`, `user_id`);

CREATE UNIQUE INDEX `article_visibility_set_members_index_3` ON `article_visibility_set_members` (`set_id`, `user_id`);

CREATE UNIQUE INDEX `article_views_index_4` ON `article_views` (`article_id`, `user_id`);

CREATE UNIQUE INDEX `article_bookmarks_index_5` ON `article_bookmarks` (`article_id`, `user_id`);

CREATE UNIQUE INDEX `call_participants_index_6` ON `call_participants` (`call_id`, `user_id`);

CREATE UNIQUE INDEX `status_visbility_set_members_index_7` ON `status_visbility_set_members` (`set_id`, `user_id`);

CREATE UNIQUE INDEX `status_views_index_8` ON `status_views` (`status_id`, `user_id`);

ALTER TABLE `message_media` COMMENT = 'Stores media meta_data related to messages';

ALTER TABLE `message_recalls` COMMENT = 'Stores messages whose format is recallable';

ALTER TABLE `message_schedules` COMMENT = 'Stores scheduled message for quick lookup by scheduler workers';

ALTER TABLE `auto_responses` COMMENT = 'Stores (key, value): (trigger, response) pairs for auto reponses';

ALTER TABLE `message_visibility_sets` COMMENT = 'Sets/collections storing meta_data for the specified category of people to which a message is visible to in group chats';

ALTER TABLE `message_visibility_set_members` COMMENT = 'Storage for members and the set to which they are included to either have the message visible or invisible to them';

ALTER TABLE `article_interactions` COMMENT = 'Store user interactions with the given article';

ALTER TABLE `status_replies` COMMENT = 'This will be used to build a direct message to the chat referenced by attribute chat id';

ALTER TABLE `users` ADD FOREIGN KEY (`id`) REFERENCES `verifications` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `users` ADD FOREIGN KEY (`id`) REFERENCES `profile_photo` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `chat_participants` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `chat_participants` ADD FOREIGN KEY (`chat_id`) REFERENCES `chats` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `messages` ADD FOREIGN KEY (`sender`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `messages` ADD FOREIGN KEY (`receiver`) REFERENCES `chats` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `message_media` ADD FOREIGN KEY (`message_id`) REFERENCES `messages` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `messages` ADD FOREIGN KEY (`id`) REFERENCES `message_recalls` (`message_id`) ON DELETE C;

ALTER TABLE `messages` ADD FOREIGN KEY (`id`) REFERENCES `message_schedules` (`message_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `read_receipts` ADD FOREIGN KEY (`message_id`) REFERENCES `messages` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `read_receipts` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `auto_responses` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `message_visibility_set_members` ADD FOREIGN KEY (`set_id`) REFERENCES `message_visibility_sets` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `message_visibility_set_members` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `articles` ADD FOREIGN KEY (`author`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `article_tags` ADD FOREIGN KEY (`article`) REFERENCES `articles` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `article_visibility_set_members` ADD FOREIGN KEY (`set_id`) REFERENCES `article_visibility_sets` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `article_visibility_set_members` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `article_interactions` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `article_interactions` ADD FOREIGN KEY (`article_id`) REFERENCES `articles` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `article_views` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `article_views` ADD FOREIGN KEY (`article_id`) REFERENCES `articles` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `article_bookmarks` ADD FOREIGN KEY (`article_id`) REFERENCES `articles` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `article_bookmarks` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `calls` ADD FOREIGN KEY (`caller`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `calls` ADD FOREIGN KEY (`callee`) REFERENCES `chats` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `call_participants` ADD FOREIGN KEY (`call_id`) REFERENCES `calls` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `call_participants` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `status_visbility_set_members` ADD FOREIGN KEY (`set_id`) REFERENCES `status_visibility_set` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `status_visbility_set_members` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `status_views` ADD FOREIGN KEY (`status_id`) REFERENCES `status_updates` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `status_views` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `status_replies` ADD FOREIGN KEY (`chat_id`) REFERENCES `chats` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `status_replies` ADD FOREIGN KEY (`status_id`) REFERENCES `status_updates` (`id`) ON DELETE SET NULL;

ALTER TABLE `status_replies` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `status_updates` ADD FOREIGN KEY (`id`) REFERENCES `status_media` (`status_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `status_updates` ADD FOREIGN KEY (`id`) REFERENCES `status_schedules` (`status_id`) ON DELETE CASCADE;
