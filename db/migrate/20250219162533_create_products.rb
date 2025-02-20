class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :title
      t.string :slug
      t.text :description
      t.decimal :price
      t.decimal :original_price
      t.decimal :discount_percentage
      t.string :source_url
      t.string :quantity
      t.string :seller_name
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
    add_index :products, :source_url, unique: true
  end
end
