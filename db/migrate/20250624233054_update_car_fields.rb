class UpdateCarFields < ActiveRecord::Migration[7.0]
  def change
    remove_column :cars, :body_type, :string
    remove_column :cars, :gearbox_type, :string
    remove_column :cars, :interior_description, :string
    remove_column :cars, :color, :string
    remove_column :cars, :mileage, :string

    add_column :cars, :horsepower, :integer
    add_column :cars, :drive, :string
  end
end
