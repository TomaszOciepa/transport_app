class OrdersController < ApplicationController
  before_action :set_order, only: [:show]

  def new
    @order = Order.new
    load_collections
  end

  def preview
    @ors_api_key = ENV["ORS_API_KEY"]
  
    if request.post?
      @order = Order.new(order_params)
      @order.combine_full_addresses
      @order.geocode_addresses
      @order.calculate_price_and_delivery
  
      session[:preview_order] = order_params
    elsif session[:preview_order]
      
      @order = Order.new(session[:preview_order])
      @order.combine_full_addresses
      @order.geocode_addresses
      @order.calculate_price_and_delivery
    else
      redirect_to new_order_path, alert: "No data to preview."
    end
  
    load_collections
  end
  


  def create
    if session[:preview_order]
      @order = Order.new(session[:preview_order])
  
      if @order.save
        session.delete(:preview_order)
        redirect_to @order, notice: "The order has been saved."
      else
        load_collections
        flash.now[:alert] = "The form contains invalid data. Please correct the errors and try again."
        render :new, status: :unprocessable_entity
      end
    else
      redirect_to new_order_path, alert: "No data to save."
    end
  end
  

  def show
    @ors_api_key = ENV["ORS_API_KEY"]
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(
      :pickup_address, :pickup_lat, :pickup_lon, :pickup_city, :pickup_postcode,
      :delivery_address, :delivery_lat, :delivery_lon, :delivery_city, :delivery_postcode,
      :vehicle_type_id, :service_type_id, :pickup_date
    )
  end

  def load_collections
    @vehicle_types = VehicleType.all
    @service_types = ServiceType.all
  end
end
