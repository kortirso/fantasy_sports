# frozen_string_literal: true

class UserUpdateValidator < ApplicationValidator
  def initialize(contract: UserUpdateContract)
    @contract = contract
  end
end
