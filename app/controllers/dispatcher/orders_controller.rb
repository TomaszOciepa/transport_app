module Dispatcher
  class OrdersController < ApplicationController
    before_action :set_order, only: [:show, :edit, :update, :destroy, :assign, :assign_driver, :assign_finalize]


    def assign
      @available_vehicles = Vehicle.where(vehicle_type_id: @order.vehicle_type_id, status: :available)
    end

    
    def assign_driver
      @vehicle = Vehicle.find(params[:vehicle_id])
      @available_drivers = Driver.where(status: :available)
                                 .where("license_category = ?", @vehicle.required_license)
    end

    
    def assign_finalize
      @vehicle = Vehicle.find(params[:vehicle_id])
      @driver = Driver.find(params[:driver_id])

      old_vehicle = @order.vehicle
      old_driver = @order.driver

      ActiveRecord::Base.transaction do
        old_vehicle&.update!(status: :available)
        old_driver&.update!(status: :available)

        @order.update!(vehicle: @vehicle, driver: @driver, status: :scheduled)
        @vehicle.update!(status: :in_transit)
        @driver.update!(status: :busy)
      end

      redirect_to dispatcher_order_path(@order), notice: "Kierowca i pojazd zostały przypisane do zamówienia."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to dispatcher_order_path(@order), alert: "Nie udało się przypisać pojazdu lub kierowcy: #{e.message}"
    end

    def index
      @orders = Order.order(pickup_date: :asc)
    end

    def show
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

    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:pickup_address, :delivery_address, :pickup_date, :delivery_date, :vehicle_type_id, :service_type_id, :status)
    end
  end
end
