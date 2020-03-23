class AddIndexToReservation < ActiveRecord::Migration[6.0]
  def change
    add_index :reservations, [:company_id, :phone_number, :reservation_date], unique: true, name: 'reservation_unique_index'
  end
end
