# frozen_string_literal: true

def authorize_user_request
  authorize_user(resource, metadata[:permitted_action])
end

def authorize_user(resource, action, request_user = nil)
  authorization("#{resource.to_s.pluralize}##{action}", request_user: request_user || {})
end

def user_logged_in
  authorization('dummy#dummy')
end

def user_logged_out
  authorization(:logged_out)
end

# rubocop:disable RSpec/VariableName
def authorization(permission, request_user: {})
  let(:Authorization) do
    return 'Bearer logged_out' if permission == :logged_out

    permissions = { permission => [*request_user[:fleets]].presence || permitted_fleet_ids }
    "Bearer #{permissions.to_json}"
  end
end

# rubocop:enable RSpec/VariableName
