# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_26_000002) do
  create_table "disease_cases", force: :cascade do |t|
    t.text "applicant_claim"
    t.text "application_content"
    t.string "body_part"
    t.string "case_no", null: false
    t.text "claim_purpose"
    t.text "committee_decision"
    t.datetime "created_at", null: false
    t.date "decided_on"
    t.string "disease_category"
    t.string "disease_name"
    t.string "link"
    t.text "medical_records"
    t.text "recognized_facts"
    t.text "related_laws"
    t.string "result"
    t.text "statement"
    t.datetime "updated_at", null: false
    t.integer "year"
    t.index ["body_part"], name: "index_disease_cases_on_body_part"
    t.index ["case_no"], name: "index_disease_cases_on_case_no", unique: true
    t.index ["decided_on"], name: "index_disease_cases_on_decided_on"
    t.index ["disease_category"], name: "index_disease_cases_on_disease_category"
    t.index ["disease_name"], name: "index_disease_cases_on_disease_name"
    t.index ["result"], name: "index_disease_cases_on_result"
    t.index ["year"], name: "index_disease_cases_on_year"
  end

  # Virtual tables defined in this database.
  # Note that virtual tables may not work with other database engines. Be careful if changing database.
