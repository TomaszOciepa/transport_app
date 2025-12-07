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
          assign_driver_to_all_active_orders(@vehicle_driver)
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

      def assign_driver_to_all_active_orders(vehicle_driver)
        driver = vehicle_driver.driver
        vehicle = vehicle_driver.vehicle
        return unless driver&.phone.present?
      
          # 1. Get current order_vehicle
        active_order_vehicles = vehicle.order_vehicles.where(current: true)
        return if active_order_vehicles.empty?
      
        active_order_vehicles.each do |order_vehicle|
          
          order = order_vehicle.order
      
            # 2. Check if the order is active
          next unless order.delivery_date > Time.current || order.pickup_date > Time.current
      
          # 3. Check if the group already exists
          existing_group = WhatsappGroup.find_by(order_id: order.id, driver_id: driver.id)
      
          if existing_group
            Rails.logger.info("Grupa WhatsApp już istnieje dla order #{order.id} i kierowcy #{driver.id}")
            next
          end
      
          # 4. Group name
          group_name = "Zamówienie #{order.id} – #{driver.first_name} #{driver.last_name}"
      
          # 5. Create local record
          whatsapp_group = WhatsappGroup.create!(
            order_id: order.id,
            driver_id: driver.id,
            whatsapp_group_id: nil,
            name: group_name
          )
      
          # 6. Create group in Node.js
          result = CreateWhatsappGroup.call(
            group_name: group_name,
            driver_phone: driver.phone,
            message: nil
          )
      
          if result && result["group_id"].present?
            whatsapp_group.update!(whatsapp_group_id: result["group_id"])
            Rails.logger.info("Utworzono grupę WhatsApp: #{result["group_id"]}")
          else
            Rails.logger.error("❌ Błąd: CreateWhatsappGroup nie zwróciło group_id dla order #{order.id}")
          end
        end
      end
      
      

    end
  end
  