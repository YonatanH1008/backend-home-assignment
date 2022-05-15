# frozen_string_literal: true

module Api
  class ElastalertController < BaseController
    skip_before_action :authenticate_user!
    def show
      status = params[:status].to_i
      render json: "Test for status #{status}}", status: status
    end
  end
end
