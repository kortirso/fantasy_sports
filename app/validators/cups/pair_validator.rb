# frozen_string_literal: true

module Cups
  class PairValidator < ApplicationValidator
    include Deps[contract: 'contracts.cups.pair']
  end
end
