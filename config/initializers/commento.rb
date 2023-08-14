# frozen_string_literal: true

require 'commento/adapters/active_record'

Commento.configure do |config|
  config.adapter = Commento::Adapters::ActiveRecord.new
end
