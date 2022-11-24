# frozen_string_literal: true

module FantasyTeams
  class CreateJob < ApplicationJob
    prepend RailsEventStore::AsyncHandler

    queue_as :default

    def perform(event)
      fantasy_team = FantasyTeam.find_by(uuid: event.data.fetch(:fantasy_team_uuid))
      return unless fantasy_team

      Achievements::FantasyTeams::Create.award_for(fantasy_team: fantasy_team)
    end
  end
end
