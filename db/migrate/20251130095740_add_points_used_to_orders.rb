class AddPointsUsedToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :points_used, :integer, default: 0, null: false
  end
end
