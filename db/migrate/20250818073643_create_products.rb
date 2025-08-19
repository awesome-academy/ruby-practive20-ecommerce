class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :sku, limit: 100
      t.references :brand, foreign_key: true, null: true, index: false
      t.text :short_description
      t.text :description
      t.string :image_url, limit: 500
      t.decimal :base_price, precision: 12, scale: 2, null: false, default: 0.00
      t.decimal :sale_price, precision: 12, scale: 2
      t.integer :stock_quantity, null: false, default: 0
      t.boolean :has_variants, null: false, default: false
      t.boolean :is_active, null: false, default: true
      t.boolean :is_featured, null: false, default: false
      t.decimal :rating_avg, precision: 3, scale: 2, default: 0.00
      t.integer :rating_count, default: 0
      t.integer :view_count, default: 0
      t.integer :sold_count, default: 0

      t.timestamps
    end
    add_index :products, :slug, unique: true
    add_index :products, :sku, unique: true
    add_index :products, :name
    add_index :products, :brand_id
    add_index :products, [:is_featured, :is_active]
    add_index :products, :sale_price
    
    # Add check constraint for sale_price
    execute <<-SQL
      ALTER TABLE products ADD CONSTRAINT check_sale_price 
      CHECK (sale_price IS NULL OR sale_price < base_price)
    SQL
  end
end
