class Task < ApplicationRecord
    belongs_to :order
    has_many :task_assignments, dependent: :destroy

    after_save :update_order_status
  
    enum :status, [ :pending, :planned, :in_progress, :completed, :canceled ]
  
    def update_status_from_assignments!
      new_status =
        if task_assignments.empty?
          :pending
        elsif task_assignments.all?(&:planned?)
          :planned
        elsif task_assignments.any?(&:in_progress?)
          :in_progress
        elsif task_assignments.all?(&:completed?)
          :completed
        elsif task_assignments.all?(&:canceled?)
          :canceled
        else
          :pending
        end
  
      update!(status: new_status)
    end

    def current_status_i18n
      I18n.t("activerecord.attributes.task.statuses.#{status}")
    end

    def refresh_statuses!
      task_assignments.each do |ta|
        ta.check_and_start!
        ta.check_and_complete! 
      end
      update_status_from_assignments!
    end

    def update_order_status
      order.update_status_from_tasks!
    end
  end
  