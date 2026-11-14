# 단계별 사례 찾기 결과의 "쉬운 요약"(EXAONE이 공개 판정서의 요인 컬럼을 읽고 만든 글)을 조건별로 한 번만 만들어 저장한다.
# 조건 키(body_concept, job, decision)는 사전 개념 이름과 판정 결과 값뿐이다(방문자가 직접 입력한 글은 넣지 않는다).
# 없는 조건은 NULL이 아니라 빈 문자열이다(SQLite의 유일 인덱스는 NULL끼리를 서로 다른 값으로 본다).
# data_digest는 모델에 보낸 사실(건수·분포·사례 요인 컬럼)과 프롬프트 버전의 SHA-256이라, 데이터를 다시 적재하면 바뀐다.
class CreateSelfCareSummaries < ActiveRecord::Migration[8.1]
  def change
    create_table :self_care_summaries do |t|
      t.string :body_concept, null: false, default: ""
      t.string :job, null: false, default: ""
      t.string :decision, null: false, default: ""
      t.string :data_digest, null: false
      t.string :status, null: false, default: "pending" # pending / ready / failed
      t.string :model
      t.string :prompt_version
      t.datetime :generated_at
      t.json :summary_json
      t.text :error_message
      t.datetime :reviewed_at # 사람이 검토한 시각. 기록만 하고 화면 노출 조건으로 쓰지 않는다.
      t.timestamps
    end
    add_index :self_care_summaries, [ :body_concept, :job, :decision, :data_digest ], unique: true,
      name: "idx_self_care_summaries_unique"
    add_index :self_care_summaries, :status
  end
end
