# frozen_string_literal: true

class SeasonValidator < ApplicationValidator
  include Deps[contract: 'contracts.season']
end
