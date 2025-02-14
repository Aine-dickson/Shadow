CREATE TYPE "user_mode" AS ENUM (
  'casual',
  'stealth'
);

CREATE TYPE "chat_type" AS ENUM (
  'private',
  'group',
  'ghost'
);

CREATE TYPE "participant_role" AS ENUM (
  'member',
  'admin',
  'super_admin'
);

CREATE TYPE "message_type" AS ENUM (
  'media',
  'text',
  'attachment'
);

CREATE TYPE "message_format" AS ENUM (
  'view_once',
  'ordinary',
  'recallable'
);

CREATE TYPE "message_status" AS ENUM (
  'sent',
  'delivered',
  'read'
);

CREATE TYPE "interval" AS ENUM (
  'none',
  'hourly',
  'daily',
  'weekly',
  'monthly',
  'yearly'
);

CREATE TYPE "message_visibility" AS ENUM (
  'all',
  'selected',
  'except_selected'
);

CREATE TYPE "article_status" AS ENUM (
  'draft',
  'published',
  'archived'
);

CREATE TYPE "article_visibility" AS ENUM (
  'all',
  'contacts',
  'selected',
  'except_selected'
);

CREATE TYPE "article_interaction" AS ENUM (
  'reaction',
  'comment',
  'bookmark'
);

CREATE TYPE "message_media_type" AS ENUM (
  'document',
  'video',
  'photo',
  'audio'
);

CREATE TYPE "call_type" AS ENUM (
  'video',
  'voice'
);

CREATE TYPE "call_status" AS ENUM (
  'missed',
  'ended',
  'calling',
  'ringing',
  'ongoing',
  'rejected'
);

CREATE TYPE "call_participant_role" AS ENUM (
  'initator',
  'moderator',
  'ordinary',
  'speaker'
);

CREATE TYPE "status_format" AS ENUM (
  'link',
  'text',
  'attachment',
  'media'
);

CREATE TYPE "status_visibility" AS ENUM (
  'contacts',
  'selected',
  'except_selected'
);

CREATE TYPE "reply_target" AS ENUM (
  'none',
  'status',
  'message'
);

CREATE TABLE "users" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "tel_contact" varchar UNIQUE NOT NULL,
  "email_address" varchar UNIQUE,
  "username" varchar(30),
  "mode" user_mode,
  "bio" varchar(255),
  "verified" bool NOT NULL DEFAULT false,
  "has_profile_photo" bool NOT NULL DEFAULT false,
  "last_seen" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "created_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "verifications" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "user_id" binary(16) NOT NULL,
  "secret_code" integer(6) NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "profile_photo" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "name" varchar(255) NOT NULL,
  "url" varchar(255) NOT NULL,
  "user_id" binary(16) NOT NULL
);

CREATE TABLE "chats" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "title" varchar NOT NULL,
  "last_message" text,
  "type" chat_type NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "created_by" binary(16) NOT NULL
);

CREATE TABLE "chat_participants" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "created_at" timestamp NOT NULL,
  "role" participant_role NOT NULL,
  "user_id" binary(16) NOT NULL,
  "chat_id" binary(16) NOT NULL
);

CREATE TABLE "messages" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "content" text NOT NULL,
  "sender" binary(16) NOT NULL,
  "receiver" binary(16) NOT NULL,
  "format" message_format NOT NULL,
  "type" message_type NOT NULL,
  "scheduled" bool NOT NULL DEFAULT false,
  "visibility" message_visibility NOT NULL,
  "visibility_set" binary(16),
  "status" message_status NOT NULL,
  "reply_to" reply_target NOT NULL DEFAULT 'none',
  "target_id" binary(16)
);

CREATE TABLE "message_media" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "name" varchar(255) NOT NULL,
  "url" varchar(255) NOT NULL,
  "type" message_media_type NOT NULL,
  "message_id" binary(16) NOT NULL
);

CREATE TABLE "message_recalls" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "message_id" binary(16) NOT NULL,
  "recall_at" timestamp DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "message_schedules" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "dispatch_at" timestamp NOT NULL,
  "frequency" interval NOT NULL,
  "interval_value" smallint NOT NULL,
  "message_id" binary(16) UNIQUE NOT NULL
);

CREATE TABLE "read_receipts" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "message_id" binary(16),
  "user_id" binary(16),
  "created_at" timestamp NOT NULL,
  "deliver_time" timestamp NOT NULL,
  "read_time" timestamp
);

CREATE TABLE "auto_responses" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "trigger" varchar(255) NOT NULL,
  "response" text NOT NULL,
  "user_id" binary(16) NOT NULL
);

CREATE TABLE "message_visibility_sets" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "created_at" timestamp DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp DEFAULT (CURRENT_TIMESTAMP),
  "name" varchar(255)
);

CREATE TABLE "message_visibility_set_members" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "user_id" binary(16) NOT NULL,
  "set_id" binary(16) NOT NULL
);

CREATE TABLE "articles" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "title" varchar(255) NOT NULL,
  "status" article_status NOT NULL,
  "content" text NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "published_at" timestamp DEFAULT (CURRENT_TIMESTAMP),
  "category" varchar9(25) NOT NULL,
  "author" binary(16) NOT NULL,
  "visibility" article_visibility NOT NULL,
  "visibility_set" binary(16)
);

CREATE TABLE "article_tags" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "value" varchar(15),
  "article" binary(16) NOT NULL
);

CREATE TABLE "article_visibility_sets" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "name" varchar(255) NOT NULL
);

CREATE TABLE "article_visibility_set_members" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "user_id" binary(16) NOT NULL,
  "set_id" binary(16) NOT NULL
);

CREATE TABLE "article_interactions" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "type" article_interaction NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "value" varchar(255) NOT NULL,
  "article_id" binary(16) NOT NULL,
  "user_id" binary(16) NOT NULL
);

CREATE TABLE "article_views" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "user_id" binary(16) NOT NULL,
  "article_id" binary(16) NOT NULL
);

CREATE TABLE "article_bookmarks" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT 'CURRENT_TIMESTAMP',
  "article_id" binary(16) NOT NULL,
  "user_id" binary(16) NOT NULL
);

CREATE TABLE "calls" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "type" call_type NOT NULL,
  "ended_at" timestamp,
  "started_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "status" call_status NOT NULL DEFAULT 'calling',
  "talk_time" integer DEFAULT 0,
  "caller" binary(16) NOT NULL,
  "callee" binary(16) NOT NULL
);

CREATE TABLE "call_participants" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "call_id" binary(16) NOT NULL,
  "user_id" binary(16) NOT NULL,
  "join_time" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "leave_time" timestamp,
  "role" call_participant_role NOT NULL
);

CREATE TABLE "status_updates" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "expires_at" timestamp NOT NULL,
  "format" status_format NOT NULL,
  "content" varchar(255) NOT NULL,
  "visibility" status_visibility NOT NULL,
  "visibility_set" binary(16) NOT NULL DEFAULT 'contacts',
  "expiry_time" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "status_visibility_set" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "name" varchar(255) NOT NULL
);

CREATE TABLE "status_visbility_set_members" (
  "id" binary(16) NOT NULL,
  "created_at" timestamp NOT NULL,
  "user_id" binary(16) NOT NULL,
  "set_id" binary(16) NOT NULL,
  PRIMARY KEY ("id", "created_at")
);

CREATE TABLE "status_views" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "user_id" bianry(16) NOT NULL,
  "status_id" binary(16) NOT NULL
);

CREATE TABLE "status_replies" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "user_id" binary(16) NOT NULL,
  "chat_id" binary(16) NOT NULL,
  "status_id" binary(16) NOT NULL,
  "content" text NOT NULL,
  "created_at" timestamp
);

CREATE TABLE "status_media" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "name" varchar(255) NOT NULL,
  "url" varchar(255) NOT NULL,
  "type" message_media_type,
  "status_id" binary(16) NOT NULL
);

CREATE TABLE "status_schedules" (
  "id" binary(16) PRIMARY KEY NOT NULL,
  "dispatch_at" timestamp NOT NULL,
  "frequency" interval,
  "interval_value" smallint,
  "status_id" binary(16) UNIQUE NOT NULL
);

CREATE UNIQUE INDEX ON "chat_participants" ("chat_id", "user_id");

CREATE UNIQUE INDEX ON "read_receipts" ("message_id", "user_id");

CREATE UNIQUE INDEX ON "message_visibility_set_members" ("set_id", "user_id");

CREATE UNIQUE INDEX ON "article_visibility_set_members" ("set_id", "user_id");

CREATE UNIQUE INDEX ON "article_views" ("article_id", "user_id");

CREATE UNIQUE INDEX ON "article_bookmarks" ("article_id", "user_id");

CREATE UNIQUE INDEX ON "call_participants" ("call_id", "user_id");

CREATE UNIQUE INDEX ON "status_visbility_set_members" ("set_id", "user_id");

CREATE UNIQUE INDEX ON "status_views" ("status_id", "user_id");

COMMENT ON COLUMN "messages"."format" IS 'Either, view once or recallable or ordinary format';

COMMENT ON COLUMN "messages"."visibility" IS 'The category of people to whom the message shall be sent';

COMMENT ON COLUMN "messages"."visibility_set" IS 'Specifies the set of user to whom should the message be sent or not sent for group chats';

COMMENT ON COLUMN "messages"."reply_to" IS 'Specifies whether it''s a standalone msg or a reply to status update or message';

COMMENT ON COLUMN "messages"."target_id" IS 'A reference to the message_id/status_id being replied to';

COMMENT ON TABLE "message_media" IS 'Stores media meta_data related to messages';

COMMENT ON COLUMN "message_media"."type" IS 'Either document or video or photo or audio';

COMMENT ON TABLE "message_recalls" IS 'Stores messages whose format is recallable';

COMMENT ON TABLE "message_schedules" IS 'Stores scheduled message for quick lookup by scheduler workers';

COMMENT ON COLUMN "message_schedules"."dispatch_at" IS 'Next time when message will be sent';

COMMENT ON COLUMN "message_schedules"."frequency" IS 'Defines the message should be sent after every n days for daily, weeks for weekly, ...';

COMMENT ON COLUMN "message_schedules"."interval_value" IS 'The `n` value for the wait defined by interval';

COMMENT ON TABLE "auto_responses" IS 'Stores (key, value): (trigger, response) pairs for auto reponses';

COMMENT ON COLUMN "auto_responses"."trigger" IS 'The matched key word to execute an auto response';

COMMENT ON TABLE "message_visibility_sets" IS 'Sets/collections storing meta_data for the specified category of people to which a message is visible to in group chats';

COMMENT ON TABLE "message_visibility_set_members" IS 'Storage for members and the set to which they are included to either have the message visible or invisible to them';

COMMENT ON COLUMN "articles"."status" IS 'Whether saved as a draft, or published or an archive';

COMMENT ON COLUMN "articles"."visibility" IS 'Can either be all users on systen or contacts or selected users or except_selected to have the article as part of their feed';

COMMENT ON TABLE "article_interactions" IS 'Store user interactions with the given article';

COMMENT ON COLUMN "article_interactions"."type" IS 'Can either be a reaction or a comment or bo';

COMMENT ON COLUMN "calls"."talk_time" IS 'Stored as milli_seconds';

COMMENT ON TABLE "status_replies" IS 'This will be used to build a direct message to the chat referenced by attribute chat id';

COMMENT ON COLUMN "status_replies"."user_id" IS 'The user replying to the subject status';

COMMENT ON COLUMN "status_replies"."chat_id" IS 'The chat to which the reply targets';

COMMENT ON COLUMN "status_replies"."status_id" IS 'The status being replied to';

COMMENT ON COLUMN "status_replies"."content" IS 'Body of the reply';

ALTER TABLE "users" ADD FOREIGN KEY ("id") REFERENCES "verifications" ("user_id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "users" ADD FOREIGN KEY ("id") REFERENCES "profile_photo" ("user_id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "chat_participants" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "chat_participants" ADD FOREIGN KEY ("chat_id") REFERENCES "chats" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "messages" ADD FOREIGN KEY ("sender") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "messages" ADD FOREIGN KEY ("receiver") REFERENCES "chats" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "message_media" ADD FOREIGN KEY ("message_id") REFERENCES "messages" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "messages" ADD FOREIGN KEY ("id") REFERENCES "message_recalls" ("message_id") ON DELETE C;

ALTER TABLE "messages" ADD FOREIGN KEY ("id") REFERENCES "message_schedules" ("message_id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "read_receipts" ADD FOREIGN KEY ("message_id") REFERENCES "messages" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "read_receipts" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "auto_responses" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "message_visibility_set_members" ADD FOREIGN KEY ("set_id") REFERENCES "message_visibility_sets" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "message_visibility_set_members" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "articles" ADD FOREIGN KEY ("author") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "article_tags" ADD FOREIGN KEY ("article") REFERENCES "articles" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "article_visibility_set_members" ADD FOREIGN KEY ("set_id") REFERENCES "article_visibility_sets" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "article_visibility_set_members" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "article_interactions" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "article_interactions" ADD FOREIGN KEY ("article_id") REFERENCES "articles" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "article_views" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "article_views" ADD FOREIGN KEY ("article_id") REFERENCES "articles" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "article_bookmarks" ADD FOREIGN KEY ("article_id") REFERENCES "articles" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "article_bookmarks" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "calls" ADD FOREIGN KEY ("caller") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "calls" ADD FOREIGN KEY ("callee") REFERENCES "chats" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "call_participants" ADD FOREIGN KEY ("call_id") REFERENCES "calls" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "call_participants" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "status_visbility_set_members" ADD FOREIGN KEY ("set_id") REFERENCES "status_visibility_set" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "status_visbility_set_members" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "status_views" ADD FOREIGN KEY ("status_id") REFERENCES "status_updates" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "status_views" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "status_replies" ADD FOREIGN KEY ("chat_id") REFERENCES "chats" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "status_replies" ADD FOREIGN KEY ("status_id") REFERENCES "status_updates" ("id") ON DELETE SET NULL;

ALTER TABLE "status_replies" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "status_updates" ADD FOREIGN KEY ("id") REFERENCES "status_media" ("status_id") ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE "status_updates" ADD FOREIGN KEY ("id") REFERENCES "status_schedules" ("status_id") ON DELETE CASCADE;
