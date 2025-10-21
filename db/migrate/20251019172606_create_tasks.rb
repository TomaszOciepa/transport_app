class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.references :order, null: false, foreign_key: true
      t.string :task_type
      t.integer :status
      t.references :driver, null: true, foreign_key: true
      t.references :vehicle, null: true, foreign_key: true
      t.datetime :planned_start_time
      t.datetime :planned_end_time
      t.datetime :executed_at
      t.integer :actor_id
      t.text :notes

      t.timestamps
    end
  end
end
