# frozen_string_literal: true

require 'emailbutler/adapters/active_record'

Emailbutler.configure do |config|
  credentials = Rails.application.credentials

  config.adapter = Emailbutler::Adapters::ActiveRecord.new
  config.providers = %w[smtp2go]
  config.ui_username = credentials.dig(:emailbutler, :username)
  config.ui_password = credentials.dig(:emailbutler, :password)
  config.ui_secured_environments = ['production']
end
