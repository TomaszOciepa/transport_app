# app/controllers/orders_controller.rb
class OrdersController < ApplicationController
  before_action :set_order, only: [:show]

  def index
    @orders = Order.all
  end

  def new
    @order = Order.new
    @vehicle_types = VehicleType.all
    @service_types = ServiceType.all
  end

  def create
    @order = Order.new(order_params)

    if @order.save
      redirect_to @order, notice: "Zamówienie zostało utworzone."
    else
      @vehicle_types = VehicleType.all
      @service_types = ServiceType.all
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(
      :pickup_address, :pickup_lat, :pickup_lon,
      :delivery_address, :delivery_lat, :delivery_lon,
      :vehicle_type_id, :service_type_id, :pickup_date
    )
  end
end
