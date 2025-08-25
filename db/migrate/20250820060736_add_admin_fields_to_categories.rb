class AddAdminFieldsToCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :description, :text
    add_column :categories, :icon_url, :string, limit: 500
    add_column :categories, :meta_title, :string, limit: 255
    add_column :categories, :meta_description, :text
    
    add_index :categories, :meta_title
  end
end
