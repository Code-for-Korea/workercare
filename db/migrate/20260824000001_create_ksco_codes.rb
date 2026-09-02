class CreateKscoCodes < ActiveRecord::Migration[8.1]
  def change
    create_table :ksco_codes, id: false do |t|
      t.string :code, primary_key: true
      t.string :name
      t.string :minor
      t.string :submajor
      t.string :major
      t.text :job_examples
      t.text :exclusions
    end
  end
end
