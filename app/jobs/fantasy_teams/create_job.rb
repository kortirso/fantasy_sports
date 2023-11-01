# frozen_string_literal: true

module FantasyTeams
  class CreateJob < ApplicationJob
    queue_as :default

    def perform(id:)
      fantasy_team = FantasyTeam.find_by(id: id)
      return unless fantasy_team

      Achievement.award(:fantasy_team_create, fantasy_team)
    end
  end
end
