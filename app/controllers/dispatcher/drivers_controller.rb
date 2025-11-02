module Dispatcher
  class DriversController < ApplicationController
    before_action :set_driver, only: [:show, :edit, :update, :destroy, :driver_history]

    def index
      @drivers = Driver.order(last_name: :asc)
    
      if params[:sort].present?
        case params[:sort]
        when "status"
          status_order = %i[available busy inactive]
          @drivers = @drivers.sort_by { |d| status_order.index(d.status.to_sym) rescue 999 }
          @drivers.reverse! if params[:direction] == "desc"
        else
          @drivers = @drivers.reorder("#{sort_column} #{sort_direction}")
        end
      end
    end

    def show
    end

    def new
      @driver = Driver.new
    end

    def create
      @driver = Driver.new(driver_params)
      if @driver.save
        redirect_to dispatcher_driver_path(@driver), notice: "Kierowca został dodany."
      else
        flash.now[:alert] = "Wystąpiły błędy. Sprawdź formularz."
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @driver.update(driver_params)
        redirect_to dispatcher_driver_path(@driver), notice: "Dane kierowcy zostały zaktualizowane."
      else
        flash.now[:alert] = "Wystąpiły błędy. Sprawdź formularz."
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @driver.destroy
      redirect_to dispatcher_drivers_path, notice: "Kierowca został usunięty."
    end
    
    def driver_history
      @vehicle_drivers = @driver.vehicle_drivers.order(updated_at: :desc).includes(:vehicle, :user)
    end

    private

    def set_driver
      @driver = Driver.find(params[:id])
    end

    def driver_params
      params.require(:driver).permit(
        :first_name,
        :last_name,
        :email,
        :phone,
        :license_category_id,
        :birth_year,
        :status
      )
    end

    def sort_column
      Driver.column_names.include?(params[:sort]) ? params[:sort] : "last_name"
    end
    
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

  end
end
