# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Swagger', type: :file do
  it 'validates swagger.yaml file' do
    json = YAML.load_file('swagger/v1/swagger.yaml').to_json

    expect(OpenApi::SchemaValidator.validate!(json, 3)).to be_truthy
  end
end
