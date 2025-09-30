class RemoveRouteGeometryFromOrders < ActiveRecord::Migration[8.0]
  def change
    remove_column :orders, :route_geometry, :text
  end
end
