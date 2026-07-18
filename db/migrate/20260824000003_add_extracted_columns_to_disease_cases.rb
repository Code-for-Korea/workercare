class AddExtractedColumnsToDiseaseCases < ActiveRecord::Migration[8.1]
  def change
    change_table :disease_cases, bulk: true do |t|
      t.string :job_name
      t.text :job_description
      t.string :employment_type
      t.string :work_type
      t.integer :job_tenure_months
      t.decimal :weekly_work_hours
      t.decimal :daily_work_hours
      t.text :burden_body_part
      t.text :bad_posture
      t.string :heavy_lifting
      t.decimal :max_item_weight
      t.decimal :daily_total_weight
      t.text :other_harmful_factors
      t.string :work_relevance_eval
      t.text :aggravating_factors
      t.text :main_reasoning
      t.string :death_status
      t.string :application_type

      t.index :job_name
      t.index :employment_type
      t.index :work_type
      t.index :heavy_lifting
      t.index :work_relevance_eval
      t.index :death_status
      t.index :application_type
    end
  end
end
