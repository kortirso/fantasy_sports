# frozen_string_literal: true

class Game < ApplicationRecord
  include Sourceable
  include Uuidable

  belongs_to :week
  belongs_to :home_season_team, class_name: '::Seasons::Team', foreign_key: :home_season_team_id
  belongs_to :visitor_season_team, class_name: '::Seasons::Team', foreign_key: :visitor_season_team_id

  has_many :games_players, class_name: '::Games::Player', dependent: :destroy
  has_many :teams_players, through: :games_players

  def fetcher_service
    "Import::#{week.league.sport_kind.camelize}::#{source.camelize}DataService".constantize
  end
end
