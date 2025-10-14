class Task < ApplicationRecord
    belongs_to :order
    has_many :task_assignments, dependent: :destroy
  
    enum :status, [ :planned, :in_progress, :completed, :canceled ]

    def update_status_from_assignments!
      new_status =
        if task_assignments.all?(&:planned?)
          :planned
        elsif task_assignments.any?(&:in_progress?)
          :in_progress
        elsif task_assignments.all?(&:completed?)
          :completed
        elsif task_assignments.all?(&:canceled?)
          :canceled
        else
          :planned
        end
  
      update!(status: new_status)
    end

    def current_status_i18n
      I18n.t("activerecord.attributes.task.statuses.#{status}")
    end
  end
  