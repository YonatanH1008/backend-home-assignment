# frozen_string_literal: true

class Vehicle < ApplicationRecord
  validates :vin, uniqueness: true, length: { is: 17 }, format: /\A[A-HJ-NPR-Z0-9]+\z/

  belongs_to :fleet, optional: true
end
