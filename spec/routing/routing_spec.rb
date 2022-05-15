# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'routing' do |resource, prefix|
  let(:base_path) { [prefix, resource].join('/') }

  describe resource do
    it 'routes to index' do
      expect(get: base_path)
        .to route_to(controller: base_path, action: 'index', format: :json)
    end

    it 'routes to show' do
      expect(get: "#{base_path}/id")
        .to route_to(controller: base_path, action: 'show', id: 'id', format: :json)
    end

    it 'routes to create' do
      expect(post: base_path)
        .to route_to(controller: base_path, action: 'create', format: :json)
    end

    it 'routes to update' do
      expect(put: "#{base_path}/id")
        .to route_to(controller: base_path, action: 'update', id: 'id', format: :json)
    end

    it 'routes to destroy' do
      expect(delete: "#{base_path}/id")
        .to route_to(controller: base_path, action: 'destroy', id: 'id', format: :json)
    end
  end
end

RSpec.describe 'routes', type: :routing do
  describe 'API' do
    it 'routes status check' do
      expect(get: 'api/status')
        .to route_to(controller: 'api/status', action: 'index', format: :json)
    end

    describe 'V1' do
      include_examples 'routing', 'examples', 'api/v1'
    end
  end
end
