class AddDriverOnlyToCars < ActiveRecord::Migration[8.0]
  def change
    add_column :cars, :driver_only, :boolean, default: false
  end
end
