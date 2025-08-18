class CreateProductVariants < ActiveRecord::Migration[7.0]
  def change
    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: true, index: false
      t.string :name
      t.string :sku, limit: 100, null: false
      t.decimal :price, precision: 12, scale: 2
      t.integer :stock_quantity, null: false, default: 0
      t.text :options_json
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end
    add_index :product_variants, :sku, unique: true
    add_index :product_variants, :product_id
    add_index :product_variants, :is_active
  end
end
