class AddCartSnapshotToCartItems < ActiveRecord::Migration[7.0]
  def change
    add_column :cart_items, :cart_snapshot_at, :timestamp
  end
end
