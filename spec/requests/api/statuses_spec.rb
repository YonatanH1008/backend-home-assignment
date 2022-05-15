# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Status', type: :request, resource: :example do
  describe 'GET /api/status' do
    it 'returns a status check' do
      get '/api/status'

      expect(response).to have_http_status(:ok)
    end
  end
end
