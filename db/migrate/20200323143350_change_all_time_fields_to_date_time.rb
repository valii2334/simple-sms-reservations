class ChangeAllTimeFieldsToDateTime < ActiveRecord::Migration[6.0]
  def change
    remove_column :companies, :opening_time, :time
    remove_column :companies, :closing_time, :time
    remove_column :reservations, :reservation_date, :time

    add_column :companies, :opening_time, :datetime
    add_column :companies, :closing_time, :datetime
    add_column :reservations, :reservation_date, :datetime
  end
end
