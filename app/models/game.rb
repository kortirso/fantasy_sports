# frozen_string_literal: true

class Game < ApplicationRecord
  belongs_to :week
  belongs_to :home_season_team, class_name: '::Seasons::Team', foreign_key: :home_season_team_id
  belongs_to :visitor_season_team, class_name: '::Seasons::Team', foreign_key: :visitor_season_team_id

  has_many :games_players, class_name: '::Games::Player', dependent: :destroy
  has_many :teams_players, through: :games_players

  def opposite_team_id(season_team_id)
    case season_team_id
    when visitor_season_team_id then home_season_team.team_id
    when home_season_team_id then visitor_season_team.team_id
    end
  end
end
