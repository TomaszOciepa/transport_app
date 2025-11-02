module Dispatcher
    class OrderVehiclesController < ApplicationController
      before_action :set_order
      before_action :set_order_vehicle, only: [:edit, :update]
      
      def index
        @order_vehicles = @order.order_vehicles.includes(:vehicle, :user).order(updated_at: :desc)
      end

      def new
        @order_vehicle = @order.order_vehicles.new
      
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
    end
  end
  