class CreateDiseaseCaseKscoCodes < ActiveRecord::Migration[8.1]
  def change
    create_table :disease_case_ksco_codes do |t|
      t.references :disease_case, null: false, foreign_key: true
      t.string :ksco_code_id, null: false
      t.float :similarity
    end

    add_index :disease_case_ksco_codes, [ :disease_case_id, :ksco_code_id ],
              unique: true, name: "index_disease_case_ksco_codes_on_case_and_code"
    add_index :disease_case_ksco_codes, :ksco_code_id
  end
end
