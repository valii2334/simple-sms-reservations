class AddOpeningTimeSaturdayToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :opening_time_saturday, :datetime
  end
end
