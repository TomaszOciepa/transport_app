module Dispatcher
  class OrdersController < ApplicationController
    before_action :set_order, only: [:show, :edit, :update, :destroy]

    def index


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

    def all_orders
      @orders = Order.all.order(:pickup_date)
      @page_title = "📋 Wszystkie zamówienia"
    end

    def pending_orders
      @orders = Order.order(pickup_date: :asc).select { |o| o.current_status == :pending }
      @page_title = "⏳ Zamówienia oczekujące"
    end

    def planned_orders
      @orders = Order.all.select { |o| o.current_status == :planned }
      @orders = @orders.sort_by(&:pickup_date)
      @page_title = "📅 Zamówienia zaplanowane"
    end

    def in_progress_orders
      @orders = Order.all.select { |o| o.current_status == :in_progress }
      @orders = @orders.sort_by(&:pickup_date)
      @page_title = "🚚 Zamówienia w drodze"
    end

    def completed_orders
      @orders = Order.all.select { |o| o.current_status == :completed }
      @orders = @orders.sort_by(&:pickup_date)
      @page_title = "✅ Zamówienia zakończone"
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
