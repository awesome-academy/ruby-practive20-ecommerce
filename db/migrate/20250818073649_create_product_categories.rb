class CreateProductCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :product_categories do |t|
      t.references :product, null: false, foreign_key: true, index: false
      t.references :category, null: false, foreign_key: true, index: false

      t.timestamps
    end
    add_index :product_categories, [:product_id, :category_id], unique: true
    add_index :product_categories, :category_id
  end
end
