class CreateOrderStatusHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :order_status_histories do |t|
      t.references :order, null: false, foreign_key: true
      t.integer :status, null: false
      t.text :note
      t.references :admin_user, null: true, foreign_key: { to_table: :users }
      t.datetime :changed_at, null: false

      t.timestamps
    end

    add_index :order_status_histories, [:order_id, :changed_at]
    add_index :order_status_histories, :status
  end
end
