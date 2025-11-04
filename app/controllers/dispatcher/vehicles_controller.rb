module Dispatcher
  class VehiclesController < ApplicationController
    before_action :set_vehicle, only: [:show, :edit, :update, :destroy]


    def index
      @vehicles = Vehicle.order(brand: :asc)
    
      @total_vehicles     = @vehicles.count
      @available_vehicles = @vehicles.count { |v| v.current_status == "available" }
      @unavailable_vehicles = @vehicles.count { |v| v.current_status == "unavailable" }
    
      @page_title = "📋 Pulpit pojazdów"
    
      @vehicle_availability_alerts = @vehicles.flat_map do |vehicle|
        vehicle.availabilities
                .select { |a| a.end_time >= Time.current }
                .map do |a|
          days_left = (a.end_time.to_date - Date.current).to_i
          if days_left < 7
            { vehicle: vehicle, days_left: days_left }
          end
        end.compact
      end

      @vehicles_without_driver = @vehicles.select { |v| v.current_driver.nil? }
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
