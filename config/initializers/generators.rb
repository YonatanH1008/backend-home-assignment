# frozen_string_literal: true

Rails.application.config.generators do |g|
  g.orm :active_record, primary_key_type: :uuid
  g.test_framework :rspec
  g.integration_tool :rspec
end
