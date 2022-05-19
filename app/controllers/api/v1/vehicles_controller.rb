# frozen_string_literal: true

module Api
  module V1
    # rubocop:disable Rails/LexicallyScopedActionFilter
    class VehiclesController < BaseController
      before_action :permissions_included_in_any_fleet!
      before_action -> { deny_permit_by_update!(resource.fleet_id, params[:fleet_id]) if params[:fleet_id] },
                    only: :update
      before_action -> { any_fleet_is_permitted!(resource.fleet_id) }, only: %i[show update destroy]
      before_action -> { raise ActionController::ParameterMissing, :fleet_id if params[:fleet_id].blank? },
                    only: %i[bulk_update create status_count]
      before_action -> { any_fleet_is_permitted!(params[:fleet_id]) if params[:fleet_id] }, only: %i[index create]

      def index
        vehicles     = fleet_context_scoped_model
        vehicles     = vehicles.where(vin: params[:vins]) if params[:vins].present?
        @pagy, @data = pagy(vehicles, max_items: 9_999)

        render json: @data
      end

      private

      def permitted_params
        %i[vin make model fleet_id]
      end

      def fleet_context_scoped_model
        return resource_class_model.where(fleet_id: params[:fleet_id]) if params[:fleet_id]

        return resource_class_model if all_fleets?

        resource_class_model.where(fleet_id: permitted_fleet_ids)
      end

      def deny_permit_by_update!(*ids)
        return if all_fleets? || ids.uniq.size == 1

        raise ForbiddenError if permitted_fleet_ids.intersection(ids).size == 1
      end
    end

    # rubocop:enable Rails/LexicallyScopedActionFilter
  end
end
