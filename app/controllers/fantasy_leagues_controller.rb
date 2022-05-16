# frozen_string_literal: true

class FantasyLeaguesController < ApplicationController
  skip_before_action :authenticate
  before_action :find_fantasy_league, only: %i[show]

  def show
    @fantasy_league_members = @fantasy_league.members.order(points: :desc).first(50)
  end

  private

  def find_fantasy_league
    @fantasy_league = FantasyLeague.find_by(uuid: params[:id])
    page_not_found if @fantasy_league.nil?
  end
end
