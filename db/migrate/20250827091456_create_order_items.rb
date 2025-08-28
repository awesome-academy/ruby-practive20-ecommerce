class CreateOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :variant, null: true, foreign_key: { to_table: :product_variants }  # null if no variant

      # Snapshot data at order time (for history)
      t.string :product_name, null: false
      t.string :product_sku, limit: 100
      t.string :variant_name

      # Pricing
      t.decimal :unit_price, precision: 12, scale: 2, null: false
      t.integer :quantity, null: false
      t.decimal :total_price, precision: 12, scale: 2, null: false

      t.timestamps
    end
  end
end
