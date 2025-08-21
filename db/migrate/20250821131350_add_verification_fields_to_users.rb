class AddVerificationFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :is_partner_verified, :boolean, default: false
    add_column :users, :is_phone_verified, :boolean, default: false
  end
end
