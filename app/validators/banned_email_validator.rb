# frozen_string_literal: true

class BannedEmailValidator < ApplicationValidator
  include Deps[contract: 'contracts.banned_email']
end
