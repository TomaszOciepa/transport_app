module Dispatcher
    class VehicleDriversController < ApplicationController
      before_action :set_vehicle
      before_action :set_vehicle_driver, only: [:unset_current]
  
      def index
        @vehicle_drivers = @vehicle.vehicle_drivers.order(updated_at: :desc)
      end
      

      def new
        @vehicle_driver = @vehicle.vehicle_drivers.new
      
        @drivers = Driver.includes(:license_category)
                         .select do |d|
                           d.can_drive?(@vehicle.vehicle_type) && d.current_vehicles.empty?
                         end
                         .sort_by(&:last_name)
      end
      
  
      def create
        @vehicle.vehicle_drivers.update_all(current: false)
  
        @vehicle_driver = @vehicle.vehicle_drivers.new(vehicle_driver_params)
        @vehicle_driver.current = true
        @vehicle_driver.user_id = current_user.id
  
        if @vehicle_driver.save
          
          redirect_to dispatcher_vehicle_path(@vehicle), notice: "Kierowca został przypisany do pojazdu."
        else
          @drivers = Driver.includes(:license_category)
                           .select { |d| d.can_drive?(@vehicle.vehicle_type) && d.available_for?(@vehicle) }
                           .sort_by(&:last_name)
          render :new
        end
      end
  
      def unset_current
        if @vehicle_driver.update(current: false)
          redirect_to dispatcher_vehicle_vehicle_drivers_path(@vehicle),
                      notice: "Przypisanie kierowcy zostało usunięte."
        else
          redirect_to dispatcher_vehicle_vehicle_drivers_path(@vehicle),
                      alert: "Nie udało się usunąć przypisania kierowcy."
        end
      end
  
      private
  
      def set_vehicle
        @vehicle = Vehicle.find(params[:vehicle_id])
      end
  
      def set_vehicle_driver
        @vehicle_driver = @vehicle.vehicle_drivers.find(params[:id])
      end
  
      def vehicle_driver_params
        params.require(:vehicle_driver).permit(:driver_id)
      end
      
    end
  end
  