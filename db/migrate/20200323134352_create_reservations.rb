class CreateReservations < ActiveRecord::Migration[6.0]
  def change
    create_table :reservations do |t|
      t.time :reservation_date
      t.string :phone_number
      t.integer :company_id

      t.timestamps
    end
  end
end
