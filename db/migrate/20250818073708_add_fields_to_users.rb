class AddFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :phone_number, :string, limit: 30
    add_column :users, :default_address, :text
    add_column :users, :default_recipient_name, :string
    add_column :users, :default_recipient_phone, :string, limit: 30
    add_column :users, :role, :integer, null: false, default: 0
    add_column :users, :activation_digest, :string
    add_column :users, :activated, :boolean, null: false, default: false
    add_column :users, :activated_at, :datetime
    add_column :users, :reset_digest, :string
    add_column :users, :reset_sent_at, :datetime
  end
end
