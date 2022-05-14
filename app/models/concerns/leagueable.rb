# frozen_string_literal: true

module Leagueable
  extend ActiveSupport::Concern

  included do
    has_many :fantasy_leagues, as: :leagueable, dependent: :destroy
  end
end
