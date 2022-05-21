# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Api::V1::FleetsController, type: :controller do
  before do
    request.headers['Content-Type']  = 'application/json'
    request.headers['Authorization'] = send('Authorization')
  end

  let(:fleet1) { create(:fleet) }
  let(:fleet2) { create(:fleet) }
  let(:unpermitted_fleet) { create(:fleet) }

  let(:permitted_fleet_ids) { [fleet1.id, fleet2.id] }
  let(:permitted_vehicle) { create(:vehicle, fleet_id: permitted_fleet_ids.first) }
  let(:unpermitted_vehicle) { create(:vehicle) }

  describe 'generic authorizations' do
    %i[show create update destroy].each do |action|
      include_examples 'permissions', :fleet, action
    end
  end

  describe '#index' do
    authorize_user(:fleet, :index)

    it 'does not return un-permitted fleets' do
      fleet1
      fleet2
      unpermitted_fleet

      get :index
      expect(response.parsed_body.pluck('id')).to eq([fleet1.id, fleet2.id])
    end

    context 'with fleets *' do
      authorize_user(:fleet, :index, fleets: ['*'])

      it 'returns all fleets' do
        fleet1
        fleet2
        unpermitted_fleet

        get :index
        expect(response.parsed_body.pluck('id').count).to eq(Fleet.count)
      end
    end

    context 'when include param is set' do
      before do
        fleet1
        fleet2
        permitted_vehicle
      end

      context 'with valid association' do
        it 'returns fleets with associated vehicles' do
          get :index, params: { include: 'vehicles' }

          expect(response.parsed_body.pluck('id')).to eq([fleet1.id, fleet2.id])

          fleet_with_vehicles = response.parsed_body.find { |fleet| fleet['id'] == fleet1.id }
          expect(fleet_with_vehicles['vehicles'].pluck('id')).to eq([permitted_vehicle.id])
        end
      end

      context 'with invlaid association' do
        it 'returns only fleets' do
          get :index, params: { include: 'helicopters' }

          expect(response.parsed_body.pluck('id')).to eq([fleet1.id, fleet2.id])

          fleet_with_vehicles = response.parsed_body.find { |fleet| fleet['id'] == fleet1.id }
          expect(fleet_with_vehicles['vehicles']).to be nil
        end
      end

      context 'with valid and invalid associations' do
        it 'filters out invalid associations and keeps valid ones' do
          get :index, params: { include: 'helicopters,vehicles' }

          expect(response.parsed_body.pluck('id')).to eq([fleet1.id, fleet2.id])
          fleet_with_vehicles = response.parsed_body.find { |fleet| fleet['id'] == fleet1.id }
          expect(fleet_with_vehicles['vehicles'].pluck('id')).to eq([permitted_vehicle.id])
        end
      end
    end
  end

  describe '#show' do
    context 'with fleet *' do
      authorize_user(:fleet, :show, fleets: ['*'])

      it 'allows view of any fleet' do
        get :show, params: { id: unpermitted_fleet.id }

        expect(response.parsed_body['id']).to eq(unpermitted_fleet.id)
      end
    end
  end

  describe '#update' do
    authorize_user(:fleet, :update)

    context 'with fleet *' do
      authorize_user(:fleet, :update, fleets: ['*'])

      it 'allows update of any fleet' do
        put :update, params: { id: unpermitted_fleet.id, name: 'New Name' }

        expect(unpermitted_fleet.reload.name).to eq('New Name')
      end
    end
  end

  describe '#destroy' do
    context 'with fleet *' do
      authorize_user(:fleet, :destroy, fleets: ['*'])

      it 'allows to destroy any fleet' do
        delete :destroy, params: { id: unpermitted_fleet.id }

        expect { unpermitted_fleet.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
