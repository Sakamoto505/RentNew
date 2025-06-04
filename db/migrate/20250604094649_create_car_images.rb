class CreateCarImages < ActiveRecord::Migration[8.0]
  def change
    create_table :car_images do |t|
      t.references :car, null: false, foreign_key: true
      t.text :image_data
      t.integer :position

      t.timestamps
    end
  end
end
