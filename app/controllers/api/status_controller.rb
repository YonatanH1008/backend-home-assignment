# frozen_string_literal: true

module Api
  class StatusController < BaseController
    skip_before_action :authenticate_user!
    def index
      app_name = Rails.application.class.module_parent_name
      body     = {
        message:        "#{app_name} is OK!",
        rails_app_name: app_name
      }
      render json: body, status: :ok
    end
  end
end
