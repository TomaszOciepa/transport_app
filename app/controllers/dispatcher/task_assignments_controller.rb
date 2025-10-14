module Dispatcher
    class TaskAssignmentsController < ApplicationController
        before_action :set_task
        before_action :set_assignment, only: [:edit, :update, :destroy]

        def new
            @task_assignment = @task.task_assignments.new
        end

        def create
            @task_assignment = @task.task_assignments.new(task_assignment_params)
            if @task_assignment.save
              redirect_to dispatcher_order_task_path(@task.order, @task), notice: "Przypisanie zapisane."
            else
              render :new
            end
          end
          

        def edit; end

        def update
            if @task_assignment.update(task_assignment_params)
              redirect_to dispatcher_order_task_path(@task_assignment.task.order, @task_assignment.task), notice: "Przypisanie zaktualizowane."
            else
              render :edit
            end
          end
          

          def destroy
            @task_assignment = TaskAssignment.find(params[:id])
            @task = @task_assignment.task
            @task_assignment.destroy
            redirect_to dispatcher_order_task_path(@task.order, @task), notice: "Przypisanie usunięte."
          end
          
          

        private

        def set_task
            @task = Task.find(params[:task_id])
        end

        def set_assignment
            @task_assignment = @task.task_assignments.find(params[:id])
        end

        def task_assignment_params
            params.require(:task_assignment).permit(:driver_id, :vehicle_id, :status)
        end

    end    
end    