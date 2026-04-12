CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "disease_cases" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "case_no" varchar NOT NULL, "disease_name" varchar, "result" varchar, "year" integer, "disease_category" varchar, "body_part" varchar, "link" varchar, "statement" text, "claim_purpose" text, "application_content" text, "applicant_claim" text, "medical_records" text, "recognized_facts" text, "related_laws" text, "committee_decision" text, "decided_on" date, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_disease_cases_on_case_no" ON "disease_cases" ("case_no") /*application='Workercare'*/;
CREATE INDEX "index_disease_cases_on_result" ON "disease_cases" ("result") /*application='Workercare'*/;
CREATE INDEX "index_disease_cases_on_year" ON "disease_cases" ("year") /*application='Workercare'*/;
CREATE INDEX "index_disease_cases_on_disease_category" ON "disease_cases" ("disease_category") /*application='Workercare'*/;
CREATE INDEX "index_disease_cases_on_body_part" ON "disease_cases" ("body_part") /*application='Workercare'*/;
CREATE INDEX "index_disease_cases_on_decided_on" ON "disease_cases" ("decided_on") /*application='Workercare'*/;
CREATE INDEX "index_disease_cases_on_disease_name" ON "disease_cases" ("disease_name") /*application='Workercare'*/;
CREATE VIRTUAL TABLE disease_cases_fts
USING fts5(
  application_content,
  applicant_claim,
  medical_records,
  recognized_facts,
  committee_decision,
  content='disease_cases',
  content_rowid='id',
  tokenize='unicode61'
)
/* disease_cases_fts(application_content,applicant_claim,medical_records,recognized_facts,committee_decision) */;
CREATE TABLE IF NOT EXISTS 'disease_cases_fts_data'(id INTEGER PRIMARY KEY, block BLOB);
CREATE TABLE IF NOT EXISTS 'disease_cases_fts_idx'(segid, term, pgno, PRIMARY KEY(segid, term)) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS 'disease_cases_fts_docsize'(id INTEGER PRIMARY KEY, sz BLOB);
CREATE TABLE IF NOT EXISTS 'disease_cases_fts_config'(k PRIMARY KEY, v) WITHOUT ROWID;
CREATE TRIGGER disease_cases_fts_insert
AFTER INSERT ON disease_cases BEGIN
  INSERT INTO disease_cases_fts(
    rowid,
    application_content,
    applicant_claim,
    medical_records,
    recognized_facts,
    committee_decision
  ) VALUES (
    new.id,
    new.application_content,
    new.applicant_claim,
    new.medical_records,
    new.recognized_facts,
    new.committee_decision
  );
END;
CREATE TRIGGER disease_cases_fts_delete
AFTER DELETE ON disease_cases BEGIN
  INSERT INTO disease_cases_fts(
    disease_cases_fts,
    rowid,
    application_content,
    applicant_claim,
    medical_records,
    recognized_facts,
    committee_decision
  ) VALUES (
    'delete',
    old.id,
    old.application_content,
    old.applicant_claim,
    old.medical_records,
    old.recognized_facts,
    old.committee_decision
  );
END;
CREATE TRIGGER disease_cases_fts_update
AFTER UPDATE ON disease_cases BEGIN
  INSERT INTO disease_cases_fts(
    disease_cases_fts,
    rowid,
    application_content,
    applicant_claim,
    medical_records,
    recognized_facts,
    committee_decision
  ) VALUES (
    'delete',
    old.id,
    old.application_content,
    old.applicant_claim,
    old.medical_records,
    old.recognized_facts,
    old.committee_decision
  );
  INSERT INTO disease_cases_fts(
    rowid,
    application_content,
    applicant_claim,
    medical_records,
    recognized_facts,
    committee_decision
  ) VALUES (
    new.id,
    new.application_content,
    new.applicant_claim,
    new.medical_records,
    new.recognized_facts,
    new.committee_decision
  );
END;
CREATE TABLE IF NOT EXISTS "action_mcp_session_messages" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "session_id" varchar NOT NULL, "direction" varchar DEFAULT 'client' NOT NULL, "message_type" varchar NOT NULL, "jsonrpc_id" varchar, "message_json" json, "is_ping" boolean DEFAULT FALSE NOT NULL, "request_acknowledged" boolean DEFAULT FALSE NOT NULL, "request_cancelled" boolean DEFAULT FALSE NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_action_mcp_session_messages_session_id"
FOREIGN KEY ("session_id")
  REFERENCES "action_mcp_sessions" ("id")
 ON DELETE CASCADE ON UPDATE CASCADE);
CREATE INDEX "index_action_mcp_session_messages_on_session_id" ON "action_mcp_session_messages" ("session_id") /*application='Workercare'*/;
CREATE TABLE IF NOT EXISTS "action_mcp_session_subscriptions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "session_id" varchar NOT NULL, "uri" varchar NOT NULL, "last_notification_at" datetime(6), "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_a643941a8d"
FOREIGN KEY ("session_id")
  REFERENCES "action_mcp_sessions" ("id")
 ON DELETE CASCADE);
CREATE INDEX "index_action_mcp_session_subscriptions_on_session_id" ON "action_mcp_session_subscriptions" ("session_id") /*application='Workercare'*/;
CREATE TABLE IF NOT EXISTS "action_mcp_session_tasks" ("id" varchar NOT NULL PRIMARY KEY, "session_id" varchar NOT NULL, "status" varchar DEFAULT 'working' NOT NULL, "status_message" varchar, "request_method" varchar, "request_name" varchar, "request_params" json, "result_payload" json, "ttl" integer, "poll_interval" integer, "last_updated_at" datetime(6) NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "continuation_state" json DEFAULT '{}' /*application='Workercare'*/, "progress_percent" integer /*application='Workercare'*/, "progress_message" varchar /*application='Workercare'*/, "last_step_at" datetime(6) /*application='Workercare'*/, CONSTRAINT "fk_action_mcp_session_tasks_session_id"
FOREIGN KEY ("session_id")
  REFERENCES "action_mcp_sessions" ("id")
 ON DELETE CASCADE ON UPDATE CASCADE);
CREATE INDEX "index_action_mcp_session_tasks_on_session_id" ON "action_mcp_session_tasks" ("session_id") /*application='Workercare'*/;
CREATE INDEX "index_action_mcp_session_tasks_on_status" ON "action_mcp_session_tasks" ("status") /*application='Workercare'*/;
CREATE INDEX "index_action_mcp_session_tasks_on_session_id_and_status" ON "action_mcp_session_tasks" ("session_id", "status") /*application='Workercare'*/;
CREATE INDEX "index_action_mcp_session_tasks_on_created_at" ON "action_mcp_session_tasks" ("created_at") /*application='Workercare'*/;
CREATE TABLE IF NOT EXISTS "action_mcp_sessions" ("id" varchar NOT NULL PRIMARY KEY, "role" varchar DEFAULT 'server' NOT NULL, "status" varchar DEFAULT 'pre_initialize' NOT NULL, "ended_at" datetime(6), "protocol_version" varchar, "server_capabilities" json, "client_capabilities" json, "server_info" json, "client_info" json, "initialized" boolean DEFAULT FALSE NOT NULL, "messages_count" integer DEFAULT 0 NOT NULL, "tool_registry" json DEFAULT '[]', "prompt_registry" json DEFAULT '[]', "resource_registry" json DEFAULT '[]', "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "consents" json DEFAULT '{}' NOT NULL, "session_data" json DEFAULT '{}' NOT NULL /*application='Workercare'*/);
CREATE TABLE IF NOT EXISTS "solid_mcp_messages" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "session_id" varchar(36) NOT NULL, "event_type" varchar(50) NOT NULL, "data" text, "created_at" datetime(6) NOT NULL, "delivered_at" datetime(6));
CREATE INDEX "idx_solid_mcp_messages_on_session_and_id" ON "solid_mcp_messages" ("session_id", "id") /*application='Workercare'*/;
CREATE INDEX "idx_solid_mcp_messages_on_delivered_and_created" ON "solid_mcp_messages" ("delivered_at", "created_at") /*application='Workercare'*/;
INSERT INTO "schema_migrations" (version) VALUES
('20260401000001'),
('20260327000009'),
('20260327000008'),
('20260327000007'),
('20260327000006'),
('20260327000005'),
('20260327000004'),
('20260327000003'),
('20260327000002'),
('20260327000001'),
('20260326000002'),
('20260326000001');

