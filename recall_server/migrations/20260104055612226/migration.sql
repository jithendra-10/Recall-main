BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "recall_chat_message" (
    "id" bigserial PRIMARY KEY,
    "sessionId" bigint NOT NULL,
    "sessionId" bigint NOT NULL,
    "ownerId" bigint NOT NULL,
    "role" text NOT NULL,
    "content" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "sources" json
);

-- Indexes
CREATE INDEX "chat_message_session_idx" ON "recall_chat_message" USING btree ("sessionId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "recall_chat_session" (
    "id" bigserial PRIMARY KEY,
    "ownerId" bigint NOT NULL,
    "title" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "chat_session_owner_idx" ON "recall_chat_session" USING btree ("ownerId");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "recall_contact" ADD COLUMN "bio" text;
ALTER TABLE "recall_contact" ADD COLUMN "location" text;
ALTER TABLE "recall_contact" ADD COLUMN "organization" text;
ALTER TABLE "recall_contact" ADD COLUMN "tier" bigint;
CREATE UNIQUE INDEX "contact_unique" ON "recall_contact" USING btree ("ownerId", "email");
--
-- ACTION CREATE TABLE
--
CREATE TABLE "recall_notification" (
    "id" bigserial PRIMARY KEY,
    "ownerId" bigint NOT NULL,
    "type" text NOT NULL,
    "title" text NOT NULL,
    "message" text NOT NULL,
    "relatedContactId" bigint,
    "relatedContactId" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "isRead" boolean NOT NULL,
    "actionLabel" text,
    "actionLink" text
);

-- Indexes
CREATE INDEX "notif_owner_idx" ON "recall_notification" USING btree ("ownerId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "recall_task" (
    "id" bigserial PRIMARY KEY,
    "ownerId" bigint NOT NULL,
    "title" text NOT NULL,
    "description" text,
    "isCompleted" boolean NOT NULL,
    "dueDate" timestamp without time zone,
    "relatedContactId" bigint,
    "relatedContactId" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "task_owner_idx" ON "recall_task" USING btree ("ownerId");

--
-- ACTION DROP TABLE
--
DROP TABLE "recall_user_config" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "recall_user_config" (
    "id" bigserial PRIMARY KEY,
    "userInfoId" bigint NOT NULL,
    "googleRefreshToken" text,
    "lastGmailHistoryId" text,
    "lastSyncTime" timestamp without time zone,
    "dailyBriefingTime" bigint NOT NULL,
    "isPro" boolean NOT NULL,
    "subscriptionDate" timestamp without time zone,
    "driftingAlertsEnabled" boolean NOT NULL,
    "weeklyDigestEnabled" boolean NOT NULL,
    "newMemoryAlertsEnabled" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "user_config_idx" ON "recall_user_config" USING btree ("userInfoId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "recall_chat_message"
    ADD CONSTRAINT "recall_chat_message_fk_0"
    FOREIGN KEY("sessionId")
    REFERENCES "recall_chat_session"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "recall_notification"
    ADD CONSTRAINT "recall_notification_fk_0"
    FOREIGN KEY("relatedContactId")
    REFERENCES "recall_contact"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "recall_task"
    ADD CONSTRAINT "recall_task_fk_0"
    FOREIGN KEY("relatedContactId")
    REFERENCES "recall_contact"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR recall
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('recall', '20260104055612226', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260104055612226', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20251208110420531-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110420531-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth', '20250825102351908-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250825102351908-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20251208110412389-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110412389-v3-0-0', "timestamp" = now();


COMMIT;
