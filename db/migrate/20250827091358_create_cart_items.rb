class CreateCartItems < ActiveRecord::Migration[7.0]
  def change
    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :variant, null: true, foreign_key: { to_table: :product_variants }  # null if no variant
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end
    
    add_index :cart_items, [:cart_id, :product_id, :variant_id], unique: true, 
              name: 'index_cart_items_unique_product_variant'
  end
end
