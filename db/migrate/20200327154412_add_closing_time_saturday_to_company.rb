class AddClosingTimeSaturdayToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :closing_time_saturday, :datetime
  end
end
