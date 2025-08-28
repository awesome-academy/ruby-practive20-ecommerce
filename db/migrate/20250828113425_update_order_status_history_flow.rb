class UpdateOrderStatusHistoryFlow < ActiveRecord::Migration[7.0]
  def up
    # Update existing status values to match new flow
    # Old: pending_confirmation(0), confirmed(1), processing(2), shipping(3), completed(4), cancelled(5)
    # New: pending(0), processing(1), confirmed(2), delivered(3), cancelled(4)
    
    execute <<-SQL
      UPDATE order_status_histories 
      SET status = CASE 
        WHEN status = 0 THEN 0  -- pending_confirmation -> pending
        WHEN status = 1 THEN 2  -- confirmed -> confirmed  
        WHEN status = 2 THEN 1  -- processing -> processing
        WHEN status = 3 THEN 3  -- shipping -> delivered
        WHEN status = 4 THEN 3  -- completed -> delivered
        WHEN status = 5 THEN 4  -- cancelled -> cancelled
        ELSE status
      END
    SQL
  end

  def down
    # Reverse the status mapping
    execute <<-SQL
      UPDATE order_status_histories 
      SET status = CASE 
        WHEN status = 0 THEN 0  -- pending -> pending_confirmation
        WHEN status = 1 THEN 2  -- processing -> processing
        WHEN status = 2 THEN 1  -- confirmed -> confirmed
        WHEN status = 3 THEN 4  -- delivered -> completed (prefer completed over shipping)
        WHEN status = 4 THEN 5  -- cancelled -> cancelled
        ELSE status
      END
    SQL
  end
end
