class OrdersController < ApplicationController
  before_action :set_order, only: [:show]
  before_action :authenticate_user!, only: [:create]

  def new
    @order = Order.new
    load_collections
  end

  def preview

    @ors_api_key = ENV["ORS_API_KEY"]
  
    if request.post?
      
      @order = Order.new(order_params)
      
      if params[:order][:pickup_address][" address-search"].present? &&
        params[:order][:delivery_address][" address-search"].present?
       
        pickup_address = params[:order][:pickup_address][" address-search"]
        delivery_address = params[:order][:delivery_address][" address-search"]

        @order.pickup_address = pickup_address
        @order.delivery_address = delivery_address

     end
      
      @order.combine_full_addresses
      @order.geocode_addresses
      @order.calculate_price_and_delivery
  
      session[:preview_order] = @order
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
      @order.user = current_user
      @order.status = :pending
      
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
    permitted = params.require(:order).permit(
      :pickup_address,
      :pickup_postcode,
      :pickup_city,
      :delivery_address,
      :delivery_postcode,
      :delivery_city,
      :vehicle_type_id,
      :service_type_id,
      :pickup_date,
      pickup_address: [" address-search"],
      delivery_address: [" address-search"]
    )
  
    permitted
  end
  

  def load_collections
    @vehicle_types = VehicleType.all
    @service_types = ServiceType.all
  end
end
