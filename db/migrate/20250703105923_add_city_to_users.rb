class AddCityToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :region, :string
  end
end
