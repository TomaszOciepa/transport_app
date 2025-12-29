module Dispatcher
  class VehiclesController < ApplicationController
    before_action :set_vehicle, only: [:show, :edit, :update, :destroy]


    def index
      @vehicles = Vehicle.order(brand: :asc)
    
      @total_vehicles       = @vehicles.count
      @available_vehicles   = @vehicles.count { |v| v.current_status == "available" }
      @unavailable_vehicles = @vehicles.count { |v| v.current_status == "unavailable" }
    
      @page_title = "🚗 Pojazdy"
    
    # --- Main suggestion logic ---
      @vehicles_needing_attention = []
    
      @vehicles.each do |vehicle|
        # No current driver
        if vehicle.current_driver.nil?
          @vehicles_needing_attention << {
            type: :no_driver,
            vehicle: vehicle,
            priority: 3 
          }
        else
          driver = vehicle.current_driver
    
          # Driver availability ends soon (< 7 days)
          if driver.availabilities.any?
            current_or_upcoming_driver = driver.availabilities
                                               .where("end_time >= ?", Time.current)
                                               .order(:end_time)
                                               .first
    
            if current_or_upcoming_driver
              driver_days_left = (current_or_upcoming_driver.end_time.to_date - Date.current).to_i
    
              if driver_days_left < 7
                @vehicles_needing_attention << {
                  type: :expiring_driver_availability,
                  vehicle: vehicle,
                  driver: driver,
                  days_left: driver_days_left,
                  priority: 1 # pilne
                }
              end
            end
          end
        end
    
        # Vehicle availability ends soon (< 7 days)
        current_or_upcoming_vehicle = vehicle.availabilities
                                             .where("end_time >= ?", Time.current)
                                             .order(:end_time)
                                             .first
    
        if current_or_upcoming_vehicle
          vehicle_days_left = (current_or_upcoming_vehicle.end_time.to_date - Date.current).to_i
    
          if vehicle_days_left < 7
            @vehicles_needing_attention << {
              type: :expiring_vehicle_availability,
              vehicle: vehicle,
              days_left: vehicle_days_left,
              priority: 1 
            }
          end
        end
      end
    
    # Remove duplicates (by vehicle ID)
      @vehicles_needing_attention.uniq! { |a| a[:vehicle].id }
    
      # Sorting: most urgent first, then by days_left ascending
      @vehicles_needing_attention.sort_by! do |alert|
        [
          alert[:priority] || 2,          # urgency first (1 urgent, 2 normal, 3 low)
          alert[:days_left] || 9999       # then the number of days left (ascending)
        ]
      end
    end
    
    
    def show
    end

    def new
      @vehicle = Vehicle.new
    end

    def create
      @vehicle = Vehicle.new(vehicle_params)
      if @vehicle.save
        redirect_to dispatcher_vehicle_path(@vehicle), notice: "Pojazd został dodany."
      else
        flash.now[:alert] = "Wystąpiły błędy. Sprawdź formularz."
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @vehicle.update(vehicle_params)
        redirect_to dispatcher_vehicle_path(@vehicle), notice: "Pojazd został zaktualizowany."
      else
        flash.now[:alert] = "Wystąpiły błędy. Sprawdź formularz."
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @vehicle.destroy
      redirect_to dispatcher_vehicles_path, notice: "Pojazd został usunięty."
    end

    def all_vehicles
      @vehicles = Vehicle.order(brand: :asc)
      @page_title = "👤 Wszystkie pojazdy"
    end

    def available_vehicles
      @vehicles = Vehicle.all.select { |v| v.current_status == "available" }
      @vehicles = @vehicles.sort_by(&:brand) # sort by brand ascending
      @page_title = "✅ Dostępne pojazdy"
    end

    def unavailable_vehicles
      @vehicles = Vehicle.all.select { |v| v.current_status == "unavailable" }
      @vehicles = @vehicles.sort_by(&:brand) # sort by brand ascending
      @page_title = "🚫 Niedostępne pojazdy"
    end
    

    private

    def sort_column
      Vehicle.column_names.include?(params[:sort]) ? params[:sort] : "brand"
    end
    
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def set_vehicle
      @vehicle = Vehicle.find(params[:id])
    end

    def vehicle_params
      params.require(:vehicle).permit(
        :brand,
        :registration_number,
        :vehicle_type_id
      )
    end
  end
end
