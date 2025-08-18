class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.references :parent, foreign_key: { to_table: :categories }, null: true
      t.integer :position, null: false, default: 0
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end
    add_index :categories, :slug, unique: true
    add_index :categories, [:parent_id, :position]
  end
end
