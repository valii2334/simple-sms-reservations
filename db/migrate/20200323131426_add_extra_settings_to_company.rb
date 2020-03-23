class AddExtraSettingsToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :closed_saturday, :boolean, default: false
    add_column :companies, :closed_sunday, :boolean, default: false
    add_column :companies, :temporarily_closed, :boolean, default: false
  end
end
