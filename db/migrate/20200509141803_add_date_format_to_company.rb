class AddDateFormatToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :date_format, :string, null: false, default: 'DMY' 
  end
end
