class AddDetailsToReservation < ActiveRecord::Migration[6.0]
  def change
    add_column :reservations, :details, :string
  end
end
