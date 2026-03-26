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
INSERT INTO "schema_migrations" (version) VALUES
('20260326000002'),
('20260326000001');

