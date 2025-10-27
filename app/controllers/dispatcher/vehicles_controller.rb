module Dispatcher
  class VehiclesController < ApplicationController
    before_action :set_vehicle, only: [:show, :edit, :update, :destroy]

    def index
      @vehicles = Vehicle.order(brand: :asc)
    
      if params[:sort].present?
        case params[:sort]
        when "status"
          status_order = %i[available busy inactive] 
          @vehicles = @vehicles.sort_by { |v| status_order.index(v.status.to_sym) rescue 999 }
          @vehicles.reverse! if params[:direction] == "desc"
        else
          @vehicles = @vehicles.reorder("#{sort_column} #{sort_direction}")
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
