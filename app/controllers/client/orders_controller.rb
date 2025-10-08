module Client
    class OrdersController < ApplicationController
      before_action :authenticate_user!
      before_action :set_order, only: [:show, :edit, :update, :destroy]
  
      def index
        @orders = current_user.orders.order(pickup_date: :asc)
      end
  
      def show
      end
  
      def edit
      end
  
      def update
        if @order.update(order_params)
          redirect_to dispatcher_order_path(@order), notice: "Zamówienie zostało zaktualizowane."
        else
          render :edit, status: :unprocessable_entity
        end
      end
  
      def destroy
        @order.destroy
        redirect_to dispatcher_orders_path, notice: "Zamówienie zostało usunięte."
      end
  
      private
  
      def set_order
        @order = current_user.orders.find(params[:id])
      end
  
      def order_params
        params.require(:order).permit(:pickup_address, :delivery_address, :pickup_date, :delivery_date, :vehicle_type_id, :service_type_id, :status)
      end
    end
  end
  