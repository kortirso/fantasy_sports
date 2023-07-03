# frozen_string_literal: true

module Users
  class CreateValidator < ApplicationValidator
    def initialize(contract: Users::CreateContract)
      super
    end
  end
end
