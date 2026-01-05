BEGIN;

--
-- ACTION ALTER TABLE
--
DROP INDEX "contact_unique";
ALTER TABLE "recall_contact" DROP COLUMN "bio";
ALTER TABLE "recall_contact" DROP COLUMN "tier";
ALTER TABLE "recall_contact" ADD COLUMN "tags" json;
ALTER TABLE "recall_contact" ADD COLUMN "summary" text;
--
-- ACTION ALTER TABLE
--
DROP INDEX "interaction_vector_idx";
CREATE INDEX "interaction_vec_idx" ON "recall_interaction" USING hnsw ("embedding" vector_l2_ops);
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
    "userInfoId" bigint NOT NULL,
    "googleRefreshToken" text,
    "lastGmailHistoryId" text,
    "dailyBriefingTime" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "user_config_idx" ON "recall_user_config" USING btree ("userInfoId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "recall_user_config"
    ADD CONSTRAINT "recall_user_config_fk_0"
    FOREIGN KEY("userInfoId")
    REFERENCES "serverpod_user_info"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR recall
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('recall', '20260103054502325', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260103054502325', "timestamp" = now();

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
