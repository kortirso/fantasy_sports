# frozen_string_literal: true

class Game < ApplicationRecord
  belongs_to :week
  belongs_to :home_team, class_name: 'Team', foreign_key: :home_team_id
  belongs_to :visitor_team, class_name: 'Team', foreign_key: :visitor_team_id
end
