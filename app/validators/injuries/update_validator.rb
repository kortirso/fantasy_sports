# frozen_string_literal: true

module Injuries
  class UpdateValidator < ApplicationValidator
    include Deps[contract: 'contracts.injuries.update']
  end
end
