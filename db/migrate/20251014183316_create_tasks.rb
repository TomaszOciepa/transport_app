class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.references :order, null: false, foreign_key: true
      t.string :name
      t.datetime :planned_start_time
      t.datetime :planned_end_time

      t.timestamps
    end
  end
end
