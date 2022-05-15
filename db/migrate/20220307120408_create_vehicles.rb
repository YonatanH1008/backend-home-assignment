# frozen_string_literal: true

class CreateVehicles < ActiveRecord::Migration[7.0]
  def change
    create_table :vehicles, id: :uuid do |t|
      t.uuid :fleet_id
      t.string :vin
      t.string :make
      t.string :model
      t.integer :odometer

      t.timestamps
    end
  end
end
