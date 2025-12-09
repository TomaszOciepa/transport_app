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
        driver  = vehicle_driver.driver
        vehicle = vehicle_driver.vehicle
        return unless driver&.phone.present?
      
        # 1. Pobierz wszystkie powiązania, gdzie pojazd jest przypisany jako current
        active_order_vehicles = vehicle.order_vehicles.where(current: true)
        return if active_order_vehicles.empty?
      
        # 2. Pobierz aktywne zamówienia
        active_orders = Order.where(id: active_order_vehicles.pluck(:order_id))
                             .where("delivery_date > ? OR pickup_date > ?", Time.current, Time.current)
      
        return if active_orders.empty?
      
        active_orders.each do |order|
          # 3. Czy istnieje już grupa dla tego zamówienia i kierowcy?
          existing_group = WhatsappGroup.find_by(order_id: order.id, driver_id: driver.id)
      
          if existing_group
            Rails.logger.info("Grupa WhatsApp już istnieje dla zamówienia #{order.id} i kierowcy #{driver.id}")
            next
          end
      
          # 4. Utwórz nową grupę — ta metoda jest spójna z OrderVehiclesController
          create_whatsapp_group_for_order_and_driver(order, driver)

          sleep(2)
        end
      end
      
      def create_whatsapp_group_for_order_and_driver(order, driver)
        # zabezpieczenie przed brakiem telefonu
        return unless driver.phone.present?
      
        # zabezpieczenie danych adresowych
        pickup_city   = order.pickup_address.to_s.split(",")[2].to_s.strip
        delivery_city = order.delivery_address.to_s.split(",")[2].to_s.strip
      
        # nazwa grupy
        group_name = "#{order.order_number} #{pickup_city} - #{delivery_city}"
      
        # lokalny rekord
        whatsapp_group = WhatsappGroup.create!(
          order_id: order.id,
          driver_id: driver.id,
          name: group_name
        )
      
        # wywołanie Node.js
        result = CreateWhatsappGroup.call(
          group_name: group_name,
          driver_phone: driver.phone,
          message: nil
        )
      
        if result && result["group_id"].present?
          whatsapp_group.update!(whatsapp_group_id: result["group_id"])
          Rails.logger.info("Utworzono grupę WhatsApp #{result["group_id"]} dla order #{order.id}")
        else
          Rails.logger.error("❌ Node.js nie zwrócił group_id dla order #{order.id}")
        end
      
        whatsapp_group
      end
      
      

    end
  end
  