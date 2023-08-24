# frozen_string_literal: true

module Users
  class CreateValidator < ApplicationValidator
    def contract
      Users::CreateContract
    end
  end
end
