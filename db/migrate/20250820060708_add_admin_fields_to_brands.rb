class AddAdminFieldsToBrands < ActiveRecord::Migration[7.0]
  def change
    add_column :brands, :is_active, :boolean, default: true, null: false
    add_column :brands, :position, :integer, default: 0, null: false
    
    add_index :brands, :is_active
    add_index :brands, :position
  end
end
