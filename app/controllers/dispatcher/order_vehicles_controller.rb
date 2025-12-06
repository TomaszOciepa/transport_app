module Dispatcher
    class OrderVehiclesController < ApplicationController
      before_action :set_order
      before_action :set_order_vehicle, only: [:edit, :update]
      
      def index
        @order_vehicles = @order.order_vehicles.includes(:vehicle, :user).order(updated_at: :desc)
      end
     
      def new
        @order_vehicle = @order.order_vehicles.new
        @selected_vehicle = params[:vehicle_id] ? Vehicle.find(params[:vehicle_id]) : nil
        @vehicles = Vehicle.all.select do |v|
          v.vehicle_type_id == @order.vehicle_type_id &&
          v.available_for?(@order) &&
          !@order.order_vehicles.exists?(vehicle: v, current: true)
        end
      end

      
      def create
        @order_vehicle = @order.order_vehicles.new(order_vehicle_params)
        @order_vehicle.user_id = current_user.id  
        @order_vehicle.current = true
      
        @order.order_vehicles.where.not(id: @order_vehicle.id).update_all(current: false)
      
        if @order_vehicle.save
          create_whatsapp_group(@order_vehicle)
          redirect_to dispatcher_order_path(@order), notice: "Pojazd został przypisany."
        else
          @vehicles = Vehicle.all
          render :new
        end
      end
      
  
      def edit
        @vehicles = Vehicle.all
      end
  
      def update
        @order.order_vehicles.update_all(current: false)
        if @order_vehicle.update(order_vehicle_params.merge(current: true))
          redirect_to dispatcher_order_path(@order), notice: "Pojazd został zmieniony"
        else
          @vehicles = Vehicle.all
          render :edit
        end
      end

      def unset_current
        @order_vehicle = OrderVehicle.find(params[:id])
        @order_vehicle.update!(current: false, user: current_user)
        redirect_to dispatcher_order_order_vehicles_path(@order_vehicle.order), notice: "Przypisanie pojazdu zostało usunięte."
      end

      def suggest
        @order = Order.find(params[:order_id])
      
        # Filter only vehicles that meet type and availability requirements
        @vehicles = Vehicle.includes(:orders).select do |v|
          v.vehicle_type_id == @order.vehicle_type_id &&
            v.available_for?(@order) &&
            !@order.order_vehicles.exists?(vehicle: v, current: true)
        end
      
        # For each vehicle, calculate the distance from the last order to the order pickup
        @vehicles_with_distance = @vehicles.map do |v|
          {
            vehicle: v,
            distance: v.distance_to_order(@order)
          }
        end
      
        # Sort by increasing distance (closest vehicle first)
        @vehicles_with_distance.sort_by! { |data| data[:distance] || Float::INFINITY }
      
        # km limit:
        # @vehicles_with_distance = @vehicles_with_distance.first(10)
      end
      
  
      private
  
      def set_order
        @order = Order.find(params[:order_id])
      end
  
      def set_order_vehicle
        @order_vehicle = @order.order_vehicles.find(params[:id])
      end
  
      def order_vehicle_params
        params.require(:order_vehicle).permit(:vehicle_id)
      end

      def create_whatsapp_group(order_vehicle)
        vehicle = order_vehicle.vehicle
        driver = vehicle.current_driver
        return unless driver&.phone.present?
      
        group_name = "Pojazd #{vehicle.brand} – Kierowca #{driver.last_name}"
      
        #1. We create a WhatsappGroup record in Rails
        whatsapp_group = WhatsappGroup.create!(
          order_vehicle: order_vehicle,
          whatsapp_group_id: nil,
          name: group_name
        )
      
        # 2. We call Node.js – creates a group and does not send messages
        result = CreateWhatsappGroup.call(
          group_name: group_name,
          driver_phone: driver.phone,
          message: nil   # <<< we do not send any messages
        )
      
        # 3. If Node.js returns a valid ID – we save it in the database
        if result && result["group_id"].present?
          whatsapp_group.update!(whatsapp_group_id: result["group_id"])
        else
          Rails.logger.error("❌ Nie udało się utworzyć grupy WhatsApp – brak group_id w odpowiedzi Node.js")
        end
      end
      
      
      
    end
  end
  