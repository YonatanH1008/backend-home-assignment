# frozen_string_literal: true

FactoryBot.define do
  factory :example do
    fleet_id { SecureRandom.uuid }
    string_field { Faker::Alphanumeric.unique.alpha(number: 30) }
    integer_field { SecureRandom.rand(999_999) }
  end
end
