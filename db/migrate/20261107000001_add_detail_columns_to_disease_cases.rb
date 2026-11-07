# application_type / work_type / employment_type 정규화(docs/disease-cases-normalization.md)로
# 원본 컬럼을 표준값으로 덮어쓰면 사라지는 부가 표기(시간, 괄호 수식어, 기타로 분류된 원문)를 보존한다.
class AddDetailColumnsToDiseaseCases < ActiveRecord::Migration[8.1]
  def change
    change_table :disease_cases, bulk: true do |t|
      t.string :application_type_detail
      t.string :work_type_detail
      t.string :employment_type_detail
    end
  end
end
