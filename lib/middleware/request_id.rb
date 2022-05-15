# frozen_string_literal: true

class RequestId
  def initialize(app)
    @app = app
  end

  def call(env)
    Thread.current[:request_id] = env['action_dispatch.request_id']
    @app.call(env)
  end
end
