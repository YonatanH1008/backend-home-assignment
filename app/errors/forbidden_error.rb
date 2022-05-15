# frozen_string_literal: true

class ForbiddenError < ActionController::ActionControllerError
  def initialize
    super('not authorized')
  end
end
