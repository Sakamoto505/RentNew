class AddCustomFieldsToCars < ActiveRecord::Migration[8.0]
  def change
    add_column :cars, :body_type, :string           # Тип кузова
    add_column :cars, :gearbox_type, :string        # Коробка передач
    add_column :cars, :has_air_conditioner, :boolean, default: false
    add_column :cars, :interior_description, :string
    add_column :cars, :color, :string
    add_column :cars, :mileage, :string             # Пробег
  end
end
