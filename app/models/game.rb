# frozen_string_literal: true

class Game < ApplicationRecord
  include Sourceable
  include Uuidable

  belongs_to :week, touch: true, optional: true
  belongs_to :season
  belongs_to :home_season_team, class_name: '::Seasons::Team', foreign_key: :home_season_team_id
  belongs_to :visitor_season_team, class_name: '::Seasons::Team', foreign_key: :visitor_season_team_id

  has_many :games_players, class_name: '::Games::Player', dependent: :destroy
  has_many :teams_players, through: :games_players
  has_many :external_sources, class_name: '::Games::ExternalSource', foreign_key: :game_id, dependent: :destroy

  def result_for_team(team_index)
    return if points.blank?
    return 'D' if points[0] == points[1]

    home_win = points[0] > points[1]
    return 'W' if team_index.zero? ? home_win : !home_win

    'L'
  end
end
