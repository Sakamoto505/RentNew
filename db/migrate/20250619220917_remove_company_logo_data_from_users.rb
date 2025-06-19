class RemoveCompanyLogoDataFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :company_logo_data, :text
  end
end
