# frozen_string_literal: true

require 'swagger_helper'

schema = load_schema(:fleet)

# rubocop:disable Rspec/EmptyExampleGroup
RSpec.describe 'Fleet SWAGGER', type: :request, resource: :fleet, schema: schema do
  origin_let
  let(:fleet1) { create(:fleet) }
  let(:fleet2) { create(:fleet) }
  let(:permitted_fleet_ids) { [fleet1.id, fleet2.id] }

  path "#{SWAGGER_SERVICE_PATH_PREFIX_DEFAULT}/v1/fleets" do
    origin_parameter

    test_index(skip403: true)
    test_create
  end

  path "#{SWAGGER_SERVICE_PATH_PREFIX_DEFAULT}/v1/fleets/{id}" do
    before { stub_http(:get, 'destroy_unapproved') }

    origin_parameter
    id_parameter

    test_show
    test_update
    test_destroy
  end
end
# rubocop:enable Rspec/EmptyExampleGroup
