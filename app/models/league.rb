# frozen_string_literal: true

class League < ApplicationRecord
  include Sportable

  has_many :seasons, dependent: :destroy
  has_one :active_season, -> { Season.in_progress }, class_name: 'Season', foreign_key: :league_id # rubocop: disable Rails/HasManyOrHasOneDependent

  has_many :cups, dependent: :destroy
end
