module Dispatcher
  class OrdersController < ApplicationController
    before_action :set_order, only: [:show, :edit, :update, :destroy]

    def index

      @orders = Order.order(pickup_date: :asc)

    
      if params[:sort].present?
        case params[:sort]
        when "status"
          status_order = %i[pending planned in_progress completed canceled]
    
          @orders = @orders.sort_by { |o| status_order.index(o.current_status) || 999 }
          @orders.reverse! if params[:direction] == "desc"
        else
          @orders = @orders.reorder("#{sort_column} #{sort_direction}")

        end
      end
    end
    

    def show
      @order = Order.find(params[:id])

    end
    

    def edit
      @service_types = ServiceType.all
      @vehicle_types = VehicleType.all
    end

    def update
      if @order.update(order_params)
        redirect_to dispatcher_order_path(@order), notice: "Zamówienie zostało zaktualizowane."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @order.destroy
      redirect_to dispatcher_orders_path, notice: "Zamówienie zostało usunięte."
    end

    private
    
    def sort_column
      %w[status pickup_date delivery_date service_type_id vehicle_type_id order_number].include?(params[:sort]) ? params[:sort] : "order_number"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:pickup_address, :delivery_address, :pickup_date, :delivery_date, :vehicle_type_id, :service_type_id, :status)
    end
  end
end
