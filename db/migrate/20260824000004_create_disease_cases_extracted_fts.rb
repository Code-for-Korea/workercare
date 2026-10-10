class CreateDiseaseCasesExtractedFts < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      CREATE VIRTUAL TABLE disease_cases_extracted_fts
      USING fts5(
        job_name,
        job_description,
        main_reasoning,
        other_harmful_factors,
        aggravating_factors,
        content='disease_cases',
        content_rowid='id',
        tokenize='unicode61'
      );
    SQL

    # 이 테이블은 disease_cases에 이미 존재하는 레코드들 위에 나중에 추가되는 external content
    # FTS5 테이블이다. CREATE VIRTUAL TABLE만으로는 shadow index가 비어있는 채로 남는데, 그 상태에서
    # 기존 레코드에 UPDATE가 발생하면 아래 update/delete 트리거가 "색인된 적 없는 rowid"에 대해
    # delete pseudo-row를 시도하게 되어 FTS5 내부 색인이 깨진다(SQLite3::CorruptException:
    # database disk image is malformed). 트리거를 만들기 전에 먼저 현재 상태로 rebuild해
    # 모든 기존 rowid를 색인에 채워 넣어야 이후 update/delete 트리거가 안전하게 동작한다.
    execute <<~SQL
      INSERT INTO disease_cases_extracted_fts(disease_cases_extracted_fts) VALUES('rebuild');
    SQL

    execute <<~SQL
      CREATE TRIGGER disease_cases_extracted_fts_insert
      AFTER INSERT ON disease_cases BEGIN
        INSERT INTO disease_cases_extracted_fts(
          rowid, job_name, job_description, main_reasoning,
          other_harmful_factors, aggravating_factors
        ) VALUES (
          new.id, new.job_name, new.job_description, new.main_reasoning,
          new.other_harmful_factors, new.aggravating_factors
        );
      END;
    SQL

    execute <<~SQL
      CREATE TRIGGER disease_cases_extracted_fts_delete
      AFTER DELETE ON disease_cases BEGIN
        INSERT INTO disease_cases_extracted_fts(
          disease_cases_extracted_fts,
          rowid, job_name, job_description, main_reasoning,
          other_harmful_factors, aggravating_factors
        ) VALUES (
          'delete',
          old.id, old.job_name, old.job_description, old.main_reasoning,
          old.other_harmful_factors, old.aggravating_factors
        );
      END;
    SQL

    execute <<~SQL
      CREATE TRIGGER disease_cases_extracted_fts_update
      AFTER UPDATE ON disease_cases BEGIN
        INSERT INTO disease_cases_extracted_fts(
          disease_cases_extracted_fts,
          rowid, job_name, job_description, main_reasoning,
          other_harmful_factors, aggravating_factors
        ) VALUES (
          'delete',
          old.id, old.job_name, old.job_description, old.main_reasoning,
          old.other_harmful_factors, old.aggravating_factors
        );
        INSERT INTO disease_cases_extracted_fts(
          rowid, job_name, job_description, main_reasoning,
          other_harmful_factors, aggravating_factors
        ) VALUES (
          new.id, new.job_name, new.job_description, new.main_reasoning,
          new.other_harmful_factors, new.aggravating_factors
        );
      END;
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS disease_cases_extracted_fts_update;"
    execute "DROP TRIGGER IF EXISTS disease_cases_extracted_fts_delete;"
    execute "DROP TRIGGER IF EXISTS disease_cases_extracted_fts_insert;"
    execute "DROP TABLE IF EXISTS disease_cases_extracted_fts;"
  end
end
