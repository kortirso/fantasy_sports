# frozen_string_literal: true

class SeasonValidator < ApplicationValidator
  def contract
    SeasonContract
  end
end
