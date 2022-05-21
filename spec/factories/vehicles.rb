# frozen_string_literal: true

FactoryBot.define do
  factory :vehicle do
    vin { Faker::Alphanumeric.unique.alpha(number: 17).gsub(/i|o|q/i, 'm').upcase }
    make { [true, false].sample ? Faker::Vehicle.make : nil }
    model { ([true, false].sample ? Faker::Vehicle.model(make_of_model: make) : nil) if make }

    association :fleet, strategy: :build
  end
end
