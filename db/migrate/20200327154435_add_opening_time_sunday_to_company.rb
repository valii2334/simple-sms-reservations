class AddOpeningTimeSundayToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :opening_time_sunday, :datetime
  end
end
