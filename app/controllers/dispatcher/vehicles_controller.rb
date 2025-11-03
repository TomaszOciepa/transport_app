module Dispatcher
  class VehiclesController < ApplicationController
    before_action :set_vehicle, only: [:show, :edit, :update, :destroy]


    def index
      @vehicles = Vehicle.order(brand: :asc)
    
      @total_vehicles     = @vehicles.count
      @available_vehicles = @vehicles.count { |v| v.current_status == "available" }
      @busy_vehicles      = @vehicles.count { |v| v.current_status == "busy" }
      @inactive_vehicles  = @vehicles.count { |v| v.current_status == "inactive" }
    
      @page_title = "📋 Pulpit pojazdów"
    
      # Sugestie – np. pojazdy niedostępne lub wkrótce nieaktywne
      @vehicle_status_alerts = @vehicles.flat_map do |vehicle|
        if vehicle.current_status != "available"
          [{ vehicle: vehicle, status: vehicle.current_status }]
        else
          []
        end
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
      @vehicles = @vehicles.sort_by(&:brand) # sortowanie po marce rosnąco
      @page_title = "✅ Dostępne pojazdy"
    end

    def unavailable_vehicles
      @vehicles = Vehicle.all.select { |v| v.current_status == "unavailable" }
      @vehicles = @vehicles.sort_by(&:brand) # sortowanie po marce rosnąco
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
