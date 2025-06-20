class AddCompanyAvatarDataToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :company_avatar_data, :text
  end
end
