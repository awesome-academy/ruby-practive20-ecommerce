class UpdateOrderStatusFlow < ActiveRecord::Migration[7.0]
  def up
    # Update existing orders to new status flow
    # pending_confirmation (0) -> pending (0) - no change needed
    # confirmed (1) -> confirmed (2)
    # processing (2) -> processing (1) 
    # shipping (3) -> delivered (3)
    # completed (4) -> delivered (3)
    # cancelled (5) -> cancelled (4)
    
    execute <<-SQL
      UPDATE orders 
      SET status = CASE 
        WHEN status = 1 THEN 2  -- confirmed -> confirmed (new position)
        WHEN status = 2 THEN 1  -- processing -> processing (new position)
        WHEN status = 3 THEN 3  -- shipping -> delivered
        WHEN status = 4 THEN 3  -- completed -> delivered  
        WHEN status = 5 THEN 4  -- cancelled -> cancelled (new position)
        ELSE status
      END
    SQL
    
    # Add delivered_at column
    add_column :orders, :delivered_at, :datetime
    
    # Copy shipping_at and completed_at to delivered_at for existing orders
    execute <<-SQL
      UPDATE orders 
      SET delivered_at = COALESCE(completed_at, shipping_at)
      WHERE status = 3  -- delivered status
    SQL
    
    # Remove old columns that are no longer needed
    remove_column :orders, :shipping_at, :datetime if column_exists?(:orders, :shipping_at)
    remove_column :orders, :completed_at, :datetime if column_exists?(:orders, :completed_at)
  end

  def down
    # Reverse migration
    add_column :orders, :shipping_at, :datetime
    add_column :orders, :completed_at, :datetime
    
    # Copy delivered_at back to completed_at
    execute <<-SQL
      UPDATE orders 
      SET completed_at = delivered_at
      WHERE status = 3  -- delivered status
    SQL
    
    # Revert status changes
    execute <<-SQL
      UPDATE orders 
      SET status = CASE 
        WHEN status = 2 THEN 1  -- confirmed -> confirmed (old position)
        WHEN status = 1 THEN 2  -- processing -> processing (old position)
        WHEN status = 3 THEN 4  -- delivered -> completed
        WHEN status = 4 THEN 5  -- cancelled -> cancelled (old position)
        ELSE status
      END
    SQL
    
    remove_column :orders, :delivered_at, :datetime
  end
end
