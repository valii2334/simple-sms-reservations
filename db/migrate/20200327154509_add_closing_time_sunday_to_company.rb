class AddClosingTimeSundayToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :closing_time_sunday, :datetime
  end
end
