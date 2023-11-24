# frozen_string_literal: true

module Injuries
  class CreateValidator < ApplicationValidator
    include Deps[contract: 'contracts.injuries.create']
  end
end
