# frozen_string_literal: true

module Users
  class UpdateValidator < ApplicationValidator
    include Deps[contract: 'contracts.users.update']
  end
end
