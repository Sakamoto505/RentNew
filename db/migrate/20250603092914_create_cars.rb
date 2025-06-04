class CreateCars < ActiveRecord::Migration[8.0]
  def change
    create_table :cars do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :location
      t.decimal :price
      t.string :transmission
      t.string :category
      t.string :fuel_type
      t.string :engine_capacity
      t.integer :year

      t.timestamps
    end
  end
end
