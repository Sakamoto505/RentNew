class CreateBlacklistEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :blacklist_entries do |t|
      t.string :first_name
      t.string :last_name
      t.integer :birth_year
      t.string :dl_number
      t.text :reason
      t.references :company, null: false, foreign_key: { to_table: :users }
      
      t.index [:first_name, :last_name, :birth_year]
      t.index :dl_number

      t.timestamps
    end
  end
end
