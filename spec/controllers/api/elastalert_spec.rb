# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::ElastalertController', type: :request do
  describe 'GET /api/elastalert/:status' do
    it 'renders 400 bad_request' do
      get '/api/elastalert/400'

      expect(response).to have_http_status :bad_request
    end

    it 'renders 500 internal_server_error' do
      get '/api/elastalert/500'

      expect(response).to have_http_status :internal_server_error
    end
  end
end
