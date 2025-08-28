class CreateCarts < ActiveRecord::Migration[7.0]
  def change
    create_table :carts do |t|
      t.references :user, null: true, foreign_key: true  # null for guest
      t.string :session_id, limit: 100
      t.integer :status, null: false, default: 0  # 0: active, 1: ordered

      t.timestamps
    end
    
    add_index :carts, [:session_id, :status], unique: true  # Only 1 active cart per session
    add_index :carts, :status
  end
end
