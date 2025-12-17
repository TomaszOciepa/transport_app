module Dispatcher
  class OrdersController < ApplicationController
    before_action :set_order, only: [:show, :edit, :update, :destroy]

    def index
      @page_title = "📦 Pulpit zamówień"
    
      @orders = Order.all
    
      @pending_orders     = @orders.count { |o| o.current_status == :pending }
      @planned_orders     = @orders.count { |o| o.current_status == :planned }
      @in_progress_orders = @orders.count { |o| o.current_status == :in_progress }
      @completed_orders   = @orders.count { |o| o.current_status == :completed }
      @total_orders       = @orders.size
    
      # We ignore completed or canceled orders
      active_orders = @orders.reject do |o|
        o.current_status.in?([:completed, :canceled]) ||
        (o.pickup_date.present? && o.pickup_date < Time.current.beginning_of_day)
      end
    
      # Orders requiring attention (no vehicle or no driver)
      @orders_needing_attention = active_orders.select do |order|
        if order.current_order_vehicle.nil?
          true
        elsif order.current_order_vehicle.vehicle.present?
          !order.current_order_vehicle.vehicle.vehicle_drivers.exists?(current: true)
        else
          false
        end
      end
    
      # Orders where the driver's availability is running out (< 7 days)
      @orders_with_expiring_driver = active_orders.filter_map do |order|
        vehicle = order.current_order_vehicle&.vehicle
        next unless vehicle
    
        driver = vehicle.vehicle_drivers.find_by(current: true)&.driver
        next unless driver
    
        current_or_upcoming = driver.availabilities
                                    .where("end_time >= ?", Time.current)
                                    .order(:end_time)
                                    .first
        next unless current_or_upcoming
    
        days_left = (current_or_upcoming.end_time.to_date - Date.current).to_i
        if days_left < 7
          { order: order, driver: driver, days_left: days_left }
        end
      end
    
      # Combined alerts (vehicle missing, driver missing, availability ending)
      @orders_needing_attention += @orders_with_expiring_driver.map { |x| x[:order] }
      @orders_needing_attention.uniq!
    
      # Sort by pickup date - next pickups at the top
      @orders_needing_attention = @orders_needing_attention.sort_by do |order|
        order.pickup_date.present? ? (order.pickup_date.to_date - Date.current).to_i : Float::INFINITY
      end
    end
    
    
    def show
      @order = Order.find(params[:id])
    
      # All groups for the order (historical + active)
      @whatsapp_groups = @order.whatsapp_groups.includes(:driver, :whatsapp_messages)
    
      # Current driver
      @active_driver = @order.current_order_vehicle&.vehicle&.current_driver
    
      # Active driver group (may not exist)
      @active_group = @active_driver ? 
                      @order.whatsapp_groups.find_by(driver_id: @active_driver.id) : 
                      nil

        @media_messages_by_group =
                      WhatsappMessage
                        .joins(:whatsapp_group)
                        .where(whatsapp_groups: { order_id: @order.id })
                        .where.associated(:media_attachment)   # 🔥 TO JEST KLUCZ
                        .includes(
                          :whatsapp_group,
                          media_attachment: :blob
                        )
                        .group_by(&:whatsapp_group_id)
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
