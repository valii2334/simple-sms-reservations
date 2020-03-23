class AddReservationMessageToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :reservation_message, :string
  end
end
