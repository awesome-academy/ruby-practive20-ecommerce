class CreateBrands < ActiveRecord::Migration[7.0]
  def change
    create_table :brands do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :logo_url, limit: 500

      t.timestamps
    end
    add_index :brands, :name, unique: true
    add_index :brands, :slug, unique: true
  end
end
