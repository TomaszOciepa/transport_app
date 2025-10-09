module Client
    class OrdersController < ApplicationController
      before_action :authenticate_user!
      before_action :set_order, only: [:show, :edit, :update, :destroy]
  
      def index
        sort_column = params[:sort].presence_in(%w[order_number status pickup_date delivery_date service_type_id vehicle_type_id]) || "pickup_date"
        sort_direction = params[:direction].in?(%w[asc desc]) ? params[:direction] : "asc"
      
        @orders = current_user.orders
                              .where.not(status: :canceled) 
                              .includes(:service_type, :vehicle_type)
                              .order("#{sort_column} #{sort_direction}")
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
        if @order.update(status: :canceled)
          redirect_to client_orders_path, notice: "Zamówienie zostało usunięte."
        else
          redirect_to client_orders_path, alert: "Nie udało się usunąc zamówienia."
        end
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
  