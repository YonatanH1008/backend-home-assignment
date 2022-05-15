# frozen_string_literal: true

module Api
  class ResourceController < BaseController
    include Pagy::Backend

    attr_reader :resource

    before_action :resource_params, only: %i[update create]
    before_action :find_resource, only: %i[show update destroy]

    after_action { pagy_headers_merge(@pagy) if @pagy }

    def initialize
      @resource_class = resource_class_model
      super
    end

    def index
      @pagy, @data = pagy(@resource_class.all)
      render json: @data
    end

    def show
      render json: @resource, scope: :show
    end

    def create
      resource = @resource_class.create!(resource_params)
      render json: resource, status: :created
    end

    def update
      @resource.update!(resource_params)
      render json: @resource
    end

    def destroy
      @resource.destroy!
      render json: @resource
    end

    private

    def permitted_params
      %i[name]
    end

    def resource_params
      @resource_params ||= params.require(@resource_class.to_s.underscore).permit(permitted_params)
    end

    def find_resource
      @resource = @resource_class.find(params[:id])
    end

    def resource_class_model
      controller_name.classify.constantize
    end
  end
end
