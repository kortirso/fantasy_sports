# frozen_string_literal: true

module Weeks
  class UpdateValidator < ApplicationValidator
    include Deps[contract: 'contracts.weeks.update']
  end
end
