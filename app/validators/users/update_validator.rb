# frozen_string_literal: true

module Users
  class UpdateValidator < ApplicationValidator
    def contract
      Users::UpdateContract
    end
  end
end
