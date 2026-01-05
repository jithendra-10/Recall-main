BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "recall_agenda_item" (
    "id" bigserial PRIMARY KEY,
    "ownerId" bigint NOT NULL,
    "contactId" bigint NOT NULL,
    "interactionId" bigint,
    "title" text NOT NULL,
    "description" text,
    "startTime" timestamp without time zone NOT NULL,
    "endTime" timestamp without time zone,
    "priority" text NOT NULL,
    "status" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "agenda_owner_date_idx" ON "recall_agenda_item" USING btree ("ownerId", "startTime");

--
-- ACTION DROP TABLE
--
DROP TABLE "recall_chat_message" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "recall_chat_message" (
    "id" bigserial PRIMARY KEY,
    "chatSessionId" bigint NOT NULL,
    "ownerId" bigint NOT NULL,
    "role" text NOT NULL,
    "content" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "sources" json
);

-- Indexes
CREATE INDEX "chat_message_session_idx" ON "recall_chat_message" USING btree ("chatSessionId");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "recall_notification" ALTER COLUMN "relatedContactId" SET NOT NULL;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "recall_task" ALTER COLUMN "relatedContactId" SET NOT NULL;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "recall_agenda_item"
    ADD CONSTRAINT "recall_agenda_item_fk_0"
    FOREIGN KEY("contactId")
    REFERENCES "recall_contact"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "recall_chat_message"
    ADD CONSTRAINT "recall_chat_message_fk_0"
    FOREIGN KEY("chatSessionId")
    REFERENCES "recall_chat_session"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR recall
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('recall', '20260104090447458', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260104090447458', "timestamp" = now();

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
