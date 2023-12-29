# frozen_string_literal: true

return unless Rails.env.production?

# :nocov:
Bugsnag.configure do |config|
  config.api_key = Rails.application.credentials[:secret_key_bugsnag]
end
# :nocov:
