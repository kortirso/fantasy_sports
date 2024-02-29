# frozen_string_literal: true

class CupValidator < ApplicationValidator
  include Deps[contract: 'contracts.cup']
end
