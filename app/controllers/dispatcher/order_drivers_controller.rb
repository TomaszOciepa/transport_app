module Dispatcher
    class OrderDriversController < ApplicationController
        before_action :set_order

        def new
            @order_driver = @order.order_drivers.new
            @drivers = Driver.all.select { |d| d.can_drive?(@order.vehicle_type) }

        end

        def create
           
            @order.order_drivers.update_all(current: false)

            @order_driver = @order.order_drivers.new(order_driver_params)
            @order_driver.current = true
            @order_driver.user_id = current_user.id

            if @order_driver.save
            redirect_to dispatcher_order_path(@order), notice: "Kierowca został przypisany."
            else
            @drivers = Driver.where(license_category_id: @order.vehicle_type.required_license_category_id)
            render :new
            end
        end

        private

        def set_order
            @order = Order.find(params[:order_id])
        end

        def order_driver_params
            params.require(:order_driver).permit(:driver_id)
        end
    end
  end
  