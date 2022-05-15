# frozen_string_literal: true

module Api
  class BaseController < ApplicationController
    ERRORS = YAML.load_file(Rails.root.join('config/errors.yml'))

    ERRORS.each do |error|
      rescue_from(error[:class]) do |e|
        logger.error { e.inspect }
        message = if error[:name] == :internal_server_error
                    'Internal Server Error. Please try again or contact support'
                  else
                    e.message.split("\n").first
                  end
        render json: { errors: [message] }, status: error[:name]
      end
    end

    rescue_from AuthenticationError do |e|
      render json: { errors: [e.message.split("\n").first] }, status: :unauthorized
    end
  end
end
