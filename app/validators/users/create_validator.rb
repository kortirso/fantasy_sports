# frozen_string_literal: true

module Users
  class CreateValidator < ApplicationValidator
    include Deps[contract: 'contracts.users.create']
  end
end
