# frozen_string_literal: true

class OraculValidator < ApplicationValidator
  include Deps[contract: 'contracts.oracul']
end
