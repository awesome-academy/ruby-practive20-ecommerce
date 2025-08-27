class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.string :order_number, limit: 30, null: false
      t.references :user, null: true, foreign_key: true  # null for guest

      # Order status & payment
      t.integer :status, null: false, default: 0  # pending_confirmation
      t.integer :payment_method, null: false, default: 0  # cod
      t.integer :payment_status, null: false, default: 0  # unpaid

      # Delivery info (snapshot at order time)
      t.string :recipient_name, null: false
      t.string :recipient_phone, limit: 30, null: false
      t.text :delivery_address, null: false
      t.text :note

      # Pricing
      t.decimal :subtotal_amount, precision: 12, scale: 2, null: false, default: 0.00
      t.decimal :shipping_fee, precision: 12, scale: 2, null: false, default: 0.00
      t.decimal :total_amount, precision: 12, scale: 2, null: false, default: 0.00

      # Status timestamps
      t.datetime :confirmed_at
      t.datetime :processing_at
      t.datetime :shipping_at
      t.datetime :completed_at
      t.datetime :cancelled_at
      t.text :cancelled_reason

      t.timestamps
    end

    add_index :orders, :order_number, unique: true
    add_index :orders, :status
    add_index :orders, :created_at
  end
end
