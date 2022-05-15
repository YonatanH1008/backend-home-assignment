# rubocop:disable Naming/FileName
# frozen_string_literal: true

# TODO: this is a workaround for: https://github.com/rswag/rswag/issues/318
SWAGGER_SERVICE_PATH_PREFIX_DEFAULT = '/api'
class GlobalSwagger
  class << self
    attr_accessor :service_path_prefix
  end
end

Rswag::Ui.configure do |c|
  # List the Swagger endpoints that you want to be documented through the swagger-ui
  # The first parameter is the path (absolute or relative to the UI host) to the corresponding
  # endpoint and the second is a title that will be displayed in the document selector
  # NOTE: If you're using rspec-api to expose Swagger files (under swagger_root) as JSON or YAML endpoints,
  # then the list below should correspond to the relative paths for those endpoints

  # NOTE: this is a kind of guesswork, determining this microservice's rewritten API GW path
  GlobalSwagger.service_path_prefix =
    if Rails.env.staging? || Rails.env.production?
      "/#{Rails.application.class.module_parent_name.downcase}"
    else
      SWAGGER_SERVICE_PATH_PREFIX_DEFAULT
    end
  c.swagger_endpoint "#{GlobalSwagger.service_path_prefix}/docs/v1/swagger.yaml", 'API V1 Docs'

  # Add Basic Auth in case your API is private
  # c.basic_auth_enabled = true
  # c.basic_auth_credentials 'username', 'password'
end
# rubocop:enable Naming/FileName
