class CreateAvailabilities < ActiveRecord::Migration[8.0]
  def change
    create_table :availabilities do |t|
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.string :status, null: false, default: "available"
      
      # Polimorficzne powiązanie: driver lub vehicle
      t.references :availableable, polymorphic: true, null: false

      t.timestamps
    end

    # Indeksy przyspieszające zapytania po czasie i zasobie
    add_index :availabilities, [:availableable_type, :availableable_id]
    add_index :availabilities, [:start_time, :end_time]
  end
end
