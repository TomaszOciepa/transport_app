class CreateTaskAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :task_assignments do |t|
      t.references :task, null: false, foreign_key: true
      t.references :driver, null: false, foreign_key: true
      t.references :vehicle, null: false, foreign_key: true
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
