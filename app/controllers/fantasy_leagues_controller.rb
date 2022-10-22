# frozen_string_literal: true

class FantasyLeaguesController < ApplicationController
  before_action :find_fantasy_league

  def show
    @fantasy_league_members = @fantasy_league.members.order(points: :desc).first(50)
  end

  private

  def find_fantasy_league
    @fantasy_league = FantasyLeague.find_by!(uuid: params[:id])
  end
end
