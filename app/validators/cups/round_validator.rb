# frozen_string_literal: true

module Cups
  class RoundValidator < ApplicationValidator
    include Deps[contract: 'contracts.cups.round']
  end
end
