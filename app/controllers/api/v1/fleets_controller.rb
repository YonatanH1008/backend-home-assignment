# frozen_string_literal: true

module Api
  module V1
    # rubocop:disable Rails/LexicallyScopedActionFilter
    class FleetsController < BaseController
      before_action :permissions_included_in_any_fleet!
      before_action -> { any_fleet_is_permitted!(resource.id) }, only: %i[show update destroy]

      def index
        @pagy, @data = pagy(permitted_fleets.includes(fleet_associated_resources), max_items: 9_999)

        # https://stackoverflow.com/questions/10159735/include-has-many-results-in-rest-json-result#:~:text=format.json%20%7B%20render%20json%3A%20%40list.to_json(%3Ainclude%20%3D%3E%20%3Aentries)%20%7D
        render json: @data.to_json(include: fleet_associated_resources)
      end

      private

      def permitted_params
        %i[name]
      end

      def permitted_fleets
        all_fleets? ? resource_class_model.all : resource_class_model.where(id: permitted_fleet_ids)
      end

      def fleet_associated_resources
        if params[:include]
          includes = params[:include].split(',').map(&:to_sym)

          # https://stackoverflow.com/questions/17499916/rails-determine-if-association-is-has-one-or-has-many#:~:text=You%20can%20get%20all%20the%20has_many%2C%20belongs_to%2C%20etc.%20with%20reflect_on_all_associations%20method.%20It%27s%20all%20in%20there.%20Or%20you%20can%20put%20in%20an%20association%20into%20reflect_on_association%20and%20it%20will%20tell%20you%20if%20it%20is%20a%20has_many%2C%20has_one%2C%20etc.%20Specifically%3A
          includes.select { |association| Fleet.reflect_on_association(association).present? }
        else
          []
        end
      end
    end
    # rubocop:enable Rails/LexicallyScopedActionFilter
  end
end
