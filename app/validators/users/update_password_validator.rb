# frozen_string_literal: true

module Users
  class UpdatePasswordValidator < ApplicationValidator
    include Deps[contract: 'contracts.users.update_password']
  end
end
