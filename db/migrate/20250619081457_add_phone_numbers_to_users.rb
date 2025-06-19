class AddPhoneNumbersToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :phone_1, :jsonb
    add_column :users, :phone_2, :jsonb
  end
end
