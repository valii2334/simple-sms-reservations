class ChangeClosedSaturdayAndClosedSundayCompany < ActiveRecord::Migration[6.0]
  def up
    change_column :companies, :closed_saturday, :boolean, default: true, null: false
    change_column :companies, :closed_sunday, :boolean, default: true, null: false

    change_column :companies, :opening_time, :datetime, null: false
    change_column :companies, :closing_time, :datetime, null: false
  end

  def down
    change_column :companies, :closed_saturday, :boolean, default: false
    change_column :companies, :closed_sunday, :boolean, default: false

    change_column :companies, :opening_time, :datetime
    change_column :companies, :closing_time, :datetime
  end
end
