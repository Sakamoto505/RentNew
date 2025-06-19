class AddCompanyDetailsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :website, :string
    add_column :users, :about, :text
    add_column :users, :address, :string
  end
end
