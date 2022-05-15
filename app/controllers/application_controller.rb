# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action -> { Thread.current[:request_id] = request.env['action_dispatch.request_id'] }
  before_action :authenticate_user!

  def authenticate_user!
    token      = request.headers['authorization'].gsub('Bearer ', '')
    @user_auth = Auth.token_decode(token).transform_keys(&:to_sym)
    raise AuthenticationError if @user_auth.blank?
  end

  class AuthenticationError < StandardError
    def initialize
      super('Unauthenticated')
    end
  end
end
