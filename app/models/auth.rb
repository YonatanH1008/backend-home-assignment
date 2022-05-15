# frozen_string_literal: true

class Auth
  # this is a hack for replacing the actual auth gem

  class << self
    def token_decode(token)
      return {} if token == 'logged_out'

      { permissions: JSON.parse(token) }
    end
  end
end
