class AddShippingMethodToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :shipping_method, :integer, null: false, default: 0
    add_index :orders, :shipping_method
  end
end
