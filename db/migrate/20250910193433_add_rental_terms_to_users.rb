class AddRentalTermsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :rental_terms, :text
  end
end
