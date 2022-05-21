class AddFleetAssociationToVehicles < ActiveRecord::Migration[7.0]
  def change
    # https://stackoverflow.com/questions/56454515/is-there-a-way-to-change-column-to-foreign-key
    add_foreign_key :vehicles, :fleets, column: :fleet_id
  end
end
