# frozen_string_literal: true

module Api
  module V1
    # rubocop:disable Rails/LexicallyScopedActionFilter
    class ExamplesController < BaseController
      before_action -> { permit_action(:index) }, only: %i[non_crud_action]
      before_action :permissions_included_in_any_fleet!
      before_action -> { any_fleet_is_permitted!(@resource.fleet_id) }, only: %i[show update destroy]
      before_action -> { raise ActionController::ParameterMissing, :fleet_id if params[:fleet_id].blank? },
                    only: %i[index bulk_update create status_count]
      before_action -> { any_fleet_is_permitted!(params[:fleet_id]) }, only: %i[index create]

      def index
        @pagy, @data = pagy(Example.where(fleet_id: params[:fleet_id]))
        render json: @data
      end

      private

      def permitted_params
        %i[string_field integer_field fleet_id]
      end
    end
    # rubocop:enable Rails/LexicallyScopedActionFilter
  end
end
