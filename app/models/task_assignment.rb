class TaskAssignment < ApplicationRecord
    belongs_to :task
    belongs_to :driver, optional: true
    belongs_to :vehicle, optional: true
  
    enum :status, [ :planned, :in_progress, :completed, :canceled ]
  
    after_save :update_task_status
    after_destroy :update_task_status
  
    def current_status_i18n
      I18n.t("activerecord.attributes.task_assignment.statuses.#{status}")
    end
    
    def check_and_start!
      if planned? && driver.present? && vehicle.present? && task.planned_start_time <= Time.current
        update!(status: :in_progress)
        task.update_status_from_assignments!
      end
    end
    

    private
  
    def update_task_status
      task.update_status_from_assignments!
    end
  end
  