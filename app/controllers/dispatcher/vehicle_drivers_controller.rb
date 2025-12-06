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
          add_driver_to_group(@vehicle_driver)
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

      def add_driver_to_group(vehicle_driver)
        order_vehicle = vehicle_driver.vehicle.current_order_vehicle
        return unless order_vehicle
      
        group = WhatsappGroup.find_by(order_vehicle: order_vehicle)
        return unless group
      
        driver_phone = vehicle_driver.driver.phone
      
        # Wywołanie endpointu Node.js
        begin
          uri = URI.parse("http://localhost:3005/add_to_group")
          request = Net::HTTP::Post.new(uri)
          request["Content-Type"] = "application/json"
          request.body = { group_id: group.whatsapp_group_id, phone: driver_phone }.to_json
      
          Net::HTTP.start(uri.hostname, uri.port) do |http|
            http.request(request)
          end
        rescue => e
          Rails.logger.error("Błąd dodawania kierowcy do grupy WhatsApp: #{e.message}")
        end
      end
      

    end
  end
  