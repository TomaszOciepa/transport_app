class OrdersController < ApplicationController
  before_action :set_order, only: [:show]

  def new
    @order = Order.new
    load_collections
  end

  def preview
    @order = Order.new(order_params)
    @order.geocode_addresses
    @order.calculate_price_and_delivery
    load_collections

    session[:preview_order] = order_params
  end

  def create
    if session[:preview_order]
      @order = Order.new(session[:preview_order])
      if @order.save
        session.delete(:preview_order)
        redirect_to @order, notice: "Zamówienie zostało zapisane."
      else
        redirect_to new_order_path, alert: "Nie udało się zapisać zamówienia."
      end
    else
      redirect_to new_order_path, alert: "Brak danych do zapisania."
    end
  end

  def show
  end

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

  def load_collections
    @vehicle_types = VehicleType.all
    @service_types = ServiceType.all
  end
end
