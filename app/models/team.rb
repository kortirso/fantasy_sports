# frozen_string_literal: true

class Team < ApplicationRecord
  has_many :seasons_teams, class_name: 'Seasons::Team', dependent: :destroy
  has_many :seasons, through: :seasons_teams
end
