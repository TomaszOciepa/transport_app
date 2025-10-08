module Dispatcher
  class DriversController < ApplicationController
    before_action :set_driver, only: [:show, :edit, :update, :destroy]

    def index
      @drivers = Driver.order(last_name: :asc)
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
        :license_category,
        :birth_year,
        :available_from,
        :available_to,
        :status
      )
    end
  end
end
