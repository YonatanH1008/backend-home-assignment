# frozen_string_literal: true

Rswag::Api.configure do |c|
  # Specify a root folder where Swagger JSON files are located
  # This is used by the Swagger middleware to serve requests for API descriptions
  # NOTE: If you're using rswag-specs to generate Swagger, you'll need to ensure
  # that it's configured to generate files in the same folder
  c.swagger_root = Rails.root.join('swagger').to_s

  # NOTE: this is basically a hack, see swagger-ui.rb
  c.swagger_filter = lambda do |swagger, _env|
    swagger['paths'].transform_keys! do |path|
      "#{GlobalSwagger.service_path_prefix}#{path.delete_prefix SWAGGER_SERVICE_PATH_PREFIX_DEFAULT}"
    end
  end
end
