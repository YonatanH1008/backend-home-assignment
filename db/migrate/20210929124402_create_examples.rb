# frozen_string_literal: true

class CreateExamples < ActiveRecord::Migration[6.1]
  def change
    create_table :examples, id: :uuid do |t|
      t.uuid :fleet_id, null: false
      t.string :string_field
      t.integer :integer_field

      t.timestamps

      t.index %i[fleet_id]
    end
  end
end
