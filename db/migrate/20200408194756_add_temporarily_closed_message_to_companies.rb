class AddTemporarilyClosedMessageToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :temporarily_closed_message, :string
  end
end
