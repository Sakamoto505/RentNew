class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.bigint :company_id, null: false
      t.string :plan, null: false
      t.integer :qty
      t.date :starts_at, null: false
      t.date :ends_at, null: false
      t.boolean :is_active, default: true, null: false

      t.timestamps

      t.index :company_id
      t.index [:company_id, :plan]
      t.index [:company_id, :is_active]
      t.index [:starts_at, :ends_at]
      t.index [:company_id, :is_active, :starts_at, :ends_at], name: 'idx_subscriptions_active_period'
    end

    add_foreign_key :subscriptions, :users, column: :company_id
  end
end
