module Dispatcher
  class DriversController < ApplicationController
    before_action :set_driver, only: [:show, :edit, :update, :destroy, :driver_history]

    def index
      @drivers = Driver.order(last_name: :asc) 
    
      @total_drivers       = @drivers.count
      @available_drivers   = @drivers.count { |d| d.current_status == "available" }
      @unavailable_drivers = @drivers.count { |d| d.current_status == "unavailable" }
    
      @page_title = "📋 Pulpit kierowców"
    
      @drivers_availability_alerts = @drivers.flat_map do |driver|
        driver.availabilities.select { |a| a.end_time >= Time.current }.map do |a|
          days_left = (a.end_time.to_date - Date.current).to_i
          if days_left < 7
            { driver: driver, days_left: days_left }
          end
        end.compact
      end
      
    end
      

    def show
      @driver = Driver.find(params[:id])
      @availabilities = @driver.availabilities.order(end_time: :desc)
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

    def all_drivers
      @drivers = Driver.order(last_name: :asc)
      @page_title = "👤 Wszyscy kierowcy"
    end

    def available_drivers
      @drivers = Driver.all.select { |d| d.current_status == "available" }
      @drivers = @drivers.sort_by(&:last_name)
      @page_title = "✅ Dostępni kierowcy"
    end

    def unavailable_drivers
      @drivers = Driver.all.select { |d| d.current_status == "unavailable" }
      @drivers = @drivers.sort_by(&:last_name)
      @page_title = "🚫 Niedostępni kierowcy"
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
