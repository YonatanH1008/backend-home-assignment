# frozen_string_literal: true

require 'swagger_helper'

schema = load_schema(:example)

RSpec.describe 'Example SWAGGER', type: :request, resource: :example, schema: schema do
  origin_let
  let(:permitted_fleet_ids) { [SecureRandom.uuid, SecureRandom.uuid] }

  path "#{SWAGGER_SERVICE_PATH_PREFIX_DEFAULT}/v1/examples" do
    origin_parameter

    test_index
    test_create
  end

  path "#{SWAGGER_SERVICE_PATH_PREFIX_DEFAULT}/v1/examples/{id}" do
    origin_parameter
    id_parameter

    test_show
    test_update
    test_destroy
  end
end
