# frozen_string_literal: true

class FantasyLeaguesController < ApplicationController
  before_action :find_fantasy_league
  before_action :find_fantasy_league_members

  def show
    @fantasy_team = @fantasy_league.fantasy_teams.find_by(user: Current.user)
  end

  private

  def find_fantasy_league
    @fantasy_league = FantasyLeague.find_by!(uuid: params[:id])
  end

  def find_fantasy_league_members
    @fantasy_league_members = @fantasy_league.members.order(points: :desc)
    @fantasy_league_members =
      if @fantasy_league.for_week?
        @fantasy_league_members
          .joins(:fantasy_team)
          .hashable_pluck(
            'fantasy_teams.id',
            'fantasy_teams.uuid',
            'fantasy_teams.name',
            :points,
            options: {
              rename: { 'fantasy_teams.id' => :id, 'fantasy_teams.uuid' => :uuid, 'fantasy_teams.name' => :name }
            }
          )
          .first(50)
      else
        @fantasy_league_members.hashable_pluck(:id, :uuid, :name, :points).first(50)
      end
  end
end
