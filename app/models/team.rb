# frozen_string_literal: true

class Team < ApplicationRecord
  has_many :leagues_seasons_teams, class_name: 'Leagues::Seasons::Team', dependent: :destroy
  has_many :leagues_seasons, through: :leagues_seasons_teams
end
