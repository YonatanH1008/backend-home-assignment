# frozen_string_literal: true

module Api
  module V1
    class BaseController < Api::ResourceController
      private

      def permitted_params
        raise NotImplementedError
      end

      def permissions_included_in_any_fleet!
        raise ForbiddenError if permitted_fleet_ids.empty?
      end

      def any_fleet_is_permitted!(*ids)
        raise ForbiddenError if permitted_fleet_ids.intersection(ids + ['*']).empty?
      end

      def user_auth_permissions
        @user_auth.fetch :permissions, {}
      end

      def permitted_fleet_ids
        user_auth_permissions.fetch permitted_action, []
      end

      def all_fleets?
        permitted_fleet_ids.include? '*'
      end

      def permitted_action
        @permitted_action ||= instance_variable_get(action_permission_name) || "#{controller_name}##{action_name}"
      end

      def action_permission_name
        "@#{action_name}_permission"
      end
    end
  end
end
