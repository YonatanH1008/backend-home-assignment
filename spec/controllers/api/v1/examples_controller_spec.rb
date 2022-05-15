# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable Metrics/BlockLength
RSpec.describe Api::V1::ExamplesController, type: :controller do
  before do
    request.headers['Content-Type']  = 'application/json'
    request.headers['Authorization'] = send('Authorization')
  end

  let(:permitted_fleet_ids) { [SecureRandom.uuid, SecureRandom.uuid] }
  let(:permitted_example) { create(:example, fleet_id: permitted_fleet_ids.first) }
  let(:unpermitted_example) { create(:example) }

  describe 'generic authorizations' do
    %i[index show create update destroy].each do |action|
      include_examples 'permissions', :example, action
    end
  end

  describe '#index' do
    let(:permitted_fleet_ids) { [SecureRandom.uuid, SecureRandom.uuid] }

    authorize_user(:example, :index)
    it 'does not return unpermitted examples' do
      permitted_example
      unpermitted_example

      get :index, params: { fleet_id: permitted_example.fleet_id }

      expect(response.parsed_body.map { |v| v['id'] }).to eq([permitted_example.id])
    end

    it 'filters examples by fleet_id' do
      create(:example, fleet_id: permitted_fleet_ids.first).fleet_id
      unfiltered = create(:example, fleet_id: permitted_fleet_ids.last)

      get :index, params: { fleet_id: unfiltered.fleet_id }

      expect(response.parsed_body.map { |v| v['id'] }).to eq([unfiltered.id])
    end

    it 'renders 406 not_acceptable on missing fleet_id' do
      expected = ['param is missing or the value is empty: fleet_id', 406]

      get :index

      expect([response.parsed_body['errors'][0], response.status]).to eq(expected)
    end
  end

  describe '#create' do
    authorize_user(:example, :create)

    it 'does not allow creation for unpermitted fleet' do
      post :create, params: attributes_for(:example)

      expect(response).to have_http_status :forbidden
    end
  end
end
# rubocop:enable Metrics/BlockLength
