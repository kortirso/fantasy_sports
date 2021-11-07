# frozen_string_literal: true

class ApplicationContract < Dry::Validation::Contract
  def self.call(args)
    new.call(args)
  end

  config.messages.backend = :i18n
end
