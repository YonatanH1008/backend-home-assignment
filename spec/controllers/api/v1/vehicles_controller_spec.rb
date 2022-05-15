# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Api::V1::VehiclesController, type: :controller do
  before do
    request.headers['Content-Type']  = 'application/json'
    request.headers['Authorization'] = send('Authorization')
  end

  let(:permitted_fleet_ids) { [SecureRandom.uuid, SecureRandom.uuid] }
  let(:permitted_vehicle) { create(:vehicle, fleet_id: permitted_fleet_ids.first) }
  let(:unpermitted_vehicle) { create(:vehicle) }

  describe 'generic authorizations' do
    %i[show create update destroy].each do |action|
      include_examples 'permissions', :vehicle, action
    end
  end

  describe '#index' do
    authorize_user(:vehicle, :index)

    it 'does not return unpermitted vehicles' do
      permitted_vehicle
      unpermitted_vehicle

      get :index, params: { fleet_id: permitted_vehicle.fleet_id }

      expect(response.parsed_body.pluck('id')).to eq([permitted_vehicle.id])
    end

    it 'filters vehicles by fleet_id' do
      create(:vehicle, fleet_id: nil)
      create(:vehicle, fleet_id: permitted_fleet_ids.first)
      unfiltered = create(:vehicle, fleet_id: permitted_fleet_ids.last)

      get :index, params: { fleet_id: unfiltered.fleet_id }

      expect(response.parsed_body.pluck('id')).to eq([unfiltered.id])
    end

    it 'filters vehicles by permitted_fleet_ids' do
      unpermitted_vehicle
      v1 = permitted_vehicle
      v2 = create(:vehicle, fleet_id: permitted_fleet_ids.last)

      get :index

      expect(response.parsed_body.pluck('id').to_set).to eq([v1.id, v2.id].to_set)
    end

    context 'with fleets *' do
      authorize_user(:vehicle, :index, fleets: ['*'])

      it 'returns all vehicles' do
        vehicles = create_list(:vehicle, 10).pluck(:id)

        get :index

        expect(response.parsed_body.pluck('id').to_set).to eq(vehicles.to_set)
      end
    end
  end

  describe '#create' do
    authorize_user(:vehicle, :create)

    it 'renders 422 bad_request for already registered vehicle' do
      vehicle = create(:vehicle, fleet_id: permitted_fleet_ids.first)
      post :create, params: attributes_for(:vehicle, fleet_id: vehicle.fleet_id, vin: vehicle.vin)

      expect(response).to have_http_status :unprocessable_entity
    end

    context 'with fleet *' do
      authorize_user(:vehicle, :create, fleets: ['*'])

      it 'allows creation of vehicle in any fleet' do
        post :create, params: attributes_for(:vehicle)

        expect(response).to have_http_status :success
      end
    end

    it 'requires fleet scope' do
      post :create, params: attributes_for(:vehicle).except(:fleet_id)

      expect(response.parsed_body['errors'][0]).to eq('param is missing or the value is empty: fleet_id')
    end
  end

  describe '#show' do
    context 'with fleet *' do
      authorize_user(:vehicle, :show, fleets: ['*'])

      it 'allows view of vehicle in any fleet' do
        id = create(:vehicle).id

        get :show, params: { id: id }

        expect(response.parsed_body['id']).to eq(id)
      end
    end
  end

  describe '#update' do
    authorize_user(:vehicle, :update)

    it 'updates attributes' do
      vehicle = create(:vehicle, fleet_id: permitted_fleet_ids[0])

      put :update, params: { id: vehicle.id, make: 'Lamrubini' }

      expect(vehicle.reload.make).to eq('Lamrubini')
    end

    it 'allows moving vehicle from one permitted fleet to another permitted fleet' do
      vehicle = create(:vehicle, fleet_id: permitted_fleet_ids[0])

      put :update, params: { id: vehicle.id, fleet_id: permitted_fleet_ids[1] }

      expect(vehicle.reload.fleet_id).to eq(permitted_fleet_ids[1])
    end

    it 'does not allows moving vehicle from a permitted fleet to an unpermitted fleet' do
      vehicle = create(:vehicle, fleet_id: permitted_fleet_ids[0])

      put :update, params: { id: vehicle.id, fleet_id: SecureRandom.uuid }

      expect(response).to have_http_status :forbidden
    end

    it 'does not allows moving vehicle from an unpermitted fleet to a permitted fleet' do
      vehicle = create(:vehicle, fleet_id: SecureRandom.uuid)

      put :update, params: { id: vehicle.id, fleet_id: permitted_fleet_ids[0] }

      expect(response).to have_http_status :forbidden
    end

    context 'with fleet *' do
      authorize_user(:vehicle, :show, fleets: ['*'])

      it 'allows view of vehicle in any fleet' do
        id = create(:vehicle).id

        get :show, params: { id: id }

        expect(response.parsed_body['id']).to eq(id)
      end
    end
  end

  describe '#destroy' do
    context 'with fleet *' do
      authorize_user(:vehicle, :destroy, fleets: ['*'])

      it 'can destroy any vehicle' do
        delete :destroy, params: { id: unpermitted_vehicle.id }

        expect { unpermitted_vehicle.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
