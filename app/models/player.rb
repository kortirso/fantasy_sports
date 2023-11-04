# frozen_string_literal: true

class Player < ApplicationRecord
  include Positionable

  has_many :teams_players, class_name: 'Teams::Player', dependent: :destroy
  has_many :seasons_teams, through: :teams_players

  has_one :active_teams_player, -> { Teams::Player.active }, class_name: 'Teams::Player' # rubocop: disable Rails/HasManyOrHasOneDependent
  has_one :active_seasons_team, through: :active_teams_player, source: :seasons_team

  has_many :players_seasons, class_name: 'Players::Season', dependent: :destroy
  has_many :seasons, through: :players_seasons

  delegate :team, to: :active_seasons_team

  def shirt_name
    return last_name if nickname.values.any?(&:blank?)

    nickname
  end
end
