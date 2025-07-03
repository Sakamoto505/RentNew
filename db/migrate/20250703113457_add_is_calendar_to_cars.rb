class AddIsCalendarToCars < ActiveRecord::Migration[8.0]
  def change
    add_column :cars, :is_calendar, :boolean, default: false
  end
end
