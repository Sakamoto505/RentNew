class AddCustomFieldToCars < ActiveRecord::Migration[8.0]
  def change
    add_column :cars, :custom_fields, :jsonb
  end
end
