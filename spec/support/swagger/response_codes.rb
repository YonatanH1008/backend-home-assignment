# frozen_string_literal: true

def test401
  response 401, :unauthorized do
    request_example_setup
    schema errors_schema
    user_logged_out
    let(:fleet_id) { SecureRandom.uuid }

    it 'returns a valid 401 response' do |example|
      submit_request(example.metadata)
      assert_response_matches_metadata(example.metadata)
    end
  end
end

def test403
  response 403, :forbidden do
    request_example_setup
    schema errors_schema
    user_logged_in
    let(:fleet_id) { SecureRandom.uuid }

    it 'returns a valid 403 response' do |example|
      submit_request(example.metadata)
      assert_response_matches_metadata(example.metadata)
    end
  end
end

def test404
  resource = metadata[:resource]
  response 404, 'not found' do
    request_example_setup
    schema errors_schema
    authorize_user_request

    let(:id) { 'nonexistent_id' }
    let(resource) { { resource => { allowed_param_sample => 'blank' } } }

    it 'returns a valid 404 response' do |example|
      submit_request(example.metadata)
      assert_response_matches_metadata(example.metadata)
    end
  end
end

def allowed_param_sample
  self.class.metadata[:schema][:base_attributes].first[0]
end
