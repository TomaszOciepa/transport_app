module Dispatcher
    class AvailabilitiesController < ApplicationController
        before_action :set_availableable

        def new
            @availability = @availableable.availabilities.new
        end

        def create
            @availability = @availableable.availabilities.new(availability_params)

            if @availability.save
              if @availableable.is_a?(Driver)
                redirect_to dispatcher_driver_path(@availableable), notice: "Dostępność została dodana."
              elsif @availableable.is_a?(Vehicle)
                redirect_to dispatcher_vehicle_path(@availableable), notice: "Dostępność została dodana."
              else
                redirect_to dispatcher_root_path, notice: "Dostępność została dodana."
              end
            else
              render :new
            end
        end



        def edit
            @availability = @availableable.availabilities.find(params[:id])
        end

        def update
            @availability = @availableable.availabilities.find(params[:id])
            if @availability.update(availability_params)
            redirect_to redirect_path, notice: "Dostępność została zaktualizowana"
            else
            render :edit
            end
        end

        def destroy
            @availability = Availability.find(params[:id])
            @availability.destroy

            redirect_to case @availableable
            when Driver then dispatcher_driver_path(@availableable)
            when Vehicle then dispatcher_vehicle_path(@availableable)
            else dispatcher_root_path
            end,
                        notice: "Dostępność została usunięta."
        end




        private


        def set_availableable
            type = params[:availableable_type]
            id   = params[:availableable_id]
            @availableable = type.constantize.find(id)
        rescue NameError
            redirect_back(fallback_location: dispatcher_root_path, alert: "Niepoprawny typ zasobu")
        end

        def availability_params
            params.require(:availability).permit(:start_time, :end_time)
        end


        def redirect_path
            if @availableable.is_a?(Driver)
            dispatcher_driver_path(@availableable)
            elsif @availableable.is_a?(Vehicle)
            dispatcher_vehicle_path(@availableable)
            else
            dispatcher_root_path
            end
        end
    end
end
