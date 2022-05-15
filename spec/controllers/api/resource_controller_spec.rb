# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Api::ResourceController, type: :controller do
  before do
    Rails.application.routes.draw { namespace(:api, defaults: { format: :json }) { resources :resource } }
    request.headers['Content-Type']  = 'application/json'
    request.headers['Authorization'] = send('Authorization')
  end

  after do
    Rails.application.reload_routes!
  end

  let(:permitted_fleet_ids) { [] }

  user_logged_in

  describe '#initizalize' do
    it 'sets @resource_class' do
      controller = described_class.new

      expect(controller.instance_variable_get('@resource_class')).to be(Resource)
    end
  end

  describe '#index' do
    it 'renders resource list' do
      get :index

      expect(response.parsed_body).to eq(Resource::RECORDS[0..19])
    end
  end

  describe '#show' do
    it 'renders resource' do
      id = rand(65)

      get :show, params: { id: id }

      expect(response.parsed_body).to eq(Resource::RECORDS[id].dup)
    end

    it 'renders 404 not_found' do
      get :show, params: { id: 'not_found' }

      expect(response).to have_http_status :not_found
    end
  end

  describe '#create' do
    it 'creates resource' do
      post :create, params: { resource: { name: 'new name' } }

      expected = [{ 'name' => 'new name' }, 201]

      expect([response.parsed_body, response.status]).to eq(expected)
    end

    it 'renders 500 internal_server_error' do
      post :create, params: { resource: { name: 'error' } }

      expect(response).to have_http_status :internal_server_error
    end

    it 'renders 406 not_acceptable on bad params' do
      expected = [{ 'errors' => ['found unpermitted parameter: :invalid_param'] }, 406]

      put :create, params: { resource: { invalid_param: 'name' } }

      expect([response.parsed_body, response.status]).to eq(expected)
    end
  end

  describe '#update' do
    it 'updates resource' do
      id = rand(65)

      put :update, params: { id: id, resource: { name: 'updated name' } }

      expect(response.parsed_body).to eq({ 'id' => id, 'name' => 'updated name' })
    end

    it 'renders 500 internal_server_error' do
      put :update, params: { id: 'update_error', resource: { name: 'name' } }

      expect(response).to have_http_status :internal_server_error
    end

    it 'renders 406 not_acceptable on bad params' do
      put :update, params: { id: 'any', resource: { invalid_param: 'name' } }

      expect(response).to have_http_status :not_acceptable
    end
  end

  describe '#destroy' do
    it 'destroys resource' do
      id = rand(65)

      delete :destroy, params: { id: id }

      expect(response.parsed_body).to eq(Resource::RECORDS[id])
    end

    it 'renders 500 internal_server_error' do
      delete :destroy, params: { id: 'destroy_error' }

      expect(response).to have_http_status :internal_server_error
    end
  end
end
# rubocop:enable Metrics/BlockLength

class Resource < ApplicationRecord
  RECORDS = (0..65).map { |i| { 'id' => i, 'name' => "name #{i}" } }
  RECORDS.define_singleton_method(:offset) do |offset|
    records = RECORDS[offset..]
    records.define_singleton_method(:limit) do |limit|
      records[0...limit]
    end
    records
  end

  class << self
    def all
      RECORDS
    end

    def find(id)
      raise ActiveRecord::RecordNotFound, '404' if id == 'not_found'

      record = RECORDS[id.to_i]

      record.define_singleton_method(:update!) do |params|
        raise StandardError, 'UpdateError' if id == 'update_error'

        record['name'] = params['name']
      end

      record.define_singleton_method(:destroy!) do
        raise StandardError, 'DestroyError' if id == 'destroy_error'

        RECORDS[id.to_i]
      end
      record
    end

    def create!(new_record)
      raise StandardError, 'CreateError' if new_record['name'] == 'error'

      new_record
    end
  end
end
