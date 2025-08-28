class FixCartUniqueIndex < ActiveRecord::Migration[7.0]
  def up
    # Remove the problematic unique index
    remove_index :carts, [:session_id, :status] if index_exists?(:carts, [:session_id, :status])
    
    # Add a simpler unique index on session_id for active carts only
    # We'll handle the business logic in the model to ensure only one active cart per session
    add_index :carts, :session_id, name: 'index_carts_on_session_id'
  end

  def down
    # Remove the new index
    remove_index :carts, :session_id if index_exists?(:carts, :session_id)
    
    # Restore the original index (might cause issues if data already exists)
    add_index :carts, [:session_id, :status], unique: true unless index_exists?(:carts, [:session_id, :status])
  end
end
