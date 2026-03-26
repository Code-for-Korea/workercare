class CreateDiseaseCasesFts < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
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
      );
    SQL

    execute <<~SQL
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
    SQL

    execute <<~SQL
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
    SQL

    execute <<~SQL
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
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS disease_cases_fts_update;"
    execute "DROP TRIGGER IF EXISTS disease_cases_fts_delete;"
    execute "DROP TRIGGER IF EXISTS disease_cases_fts_insert;"
    execute "DROP TABLE IF EXISTS disease_cases_fts;"
  end
end
