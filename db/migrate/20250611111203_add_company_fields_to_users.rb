class AddCompanyFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :company_name, :string
    add_column :users, :company_logo_data, :text
    add_column :users, :phone, :string
    add_column :users, :whatsapp, :string
    add_column :users, :telegram, :string
    add_column :users, :instagram, :string
  end
end
