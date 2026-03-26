class CreateDiseaseCases < ActiveRecord::Migration[8.1]
  def change
    create_table :disease_cases do |t|
      t.string  :case_no,              null: false
      t.string  :disease_name
      t.string  :result
      t.integer :year
      t.string  :disease_category
      t.string  :body_part
      t.string  :link
      t.text    :statement
      t.text    :claim_purpose
      t.text    :application_content
      t.text    :applicant_claim
      t.text    :medical_records
      t.text    :recognized_facts
      t.text    :related_laws
      t.text    :committee_decision
      t.date    :decided_on

      t.timestamps
    end

    add_index :disease_cases, :case_no, unique: true
    add_index :disease_cases, :result
    add_index :disease_cases, :year
    add_index :disease_cases, :disease_category
    add_index :disease_cases, :body_part
    add_index :disease_cases, :decided_on
    add_index :disease_cases, :disease_name
  end
end
