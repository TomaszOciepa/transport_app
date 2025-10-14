module Dispatcher
    class TasksController < ApplicationController
        before_action :set_order
        before_action :set_task, only: [:show, :edit, :update, :destroy]
    
        def index
        @tasks = @order.tasks
        end
    
        def show
        end
    
        def new
        @task = @order.tasks.new
        end
    
        def create
        @task = @order.tasks.new(task_params)
        if @task.save
            redirect_to dispatcher_order_path(@order), notice: "Task został utworzony."
        else
            render :new
        end
        end
    
        def edit
        end
    
        def update
        if @task.update(task_params)
            redirect_to dispatcher_order_path(@order), notice: "Task został zaktualizowany."
        else
            render :edit
        end
        end
    
        def destroy
            @order = Order.find(params[:order_id])
            @task = @order.tasks.find(params[:id])
            @task.destroy
        
            redirect_to dispatcher_order_path(@order), notice: "Task został usunięty."
        end
    
        private
    
        def set_order
        @order = Order.find(params[:order_id])
        end
    
        def set_task
        @task = @order.tasks.find(params[:id])
        end
    
        def task_params
        params.require(:task).permit(:name, :planned_start_time, :planned_end_time, :status)
        end
  end
end  