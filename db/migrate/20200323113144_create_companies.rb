class CreateCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :code
      t.time :opening_time
      t.time :closing_time
      t.integer :unit_of_time
      t.integer :customers_per_unit_of_time

      t.timestamps
    end
  end
end
