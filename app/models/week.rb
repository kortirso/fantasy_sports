# frozen_string_literal: true

class Week < ApplicationRecord
  belongs_to :leagues_season, class_name: '::Leagues::Season'

  has_many :games, dependent: :destroy

  has_many :fantasy_leagues, as: :leagueable, dependent: :destroy

  scope :active, -> { where(active: true) }
end
