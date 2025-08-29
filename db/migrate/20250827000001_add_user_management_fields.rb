class AddUserManagementFields < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :deleted_at, :datetime
    add_column :users, :inactive_reason, :text
    add_column :users, :last_login_at, :datetime
    add_column :users, :avatar_url, :string
    
    add_index :users, :deleted_at
    add_index :users, :last_login_at
    add_index :users, :activated
    add_index :users, :role
  end
end
