class CreateCompanyLogos < ActiveRecord::Migration[8.0]
  def change
    create_table :company_logos do |t|
      t.references :user, null: false, foreign_key: true
      t.text :image_data
      t.integer :position

      t.timestamps
    end
  end
end
