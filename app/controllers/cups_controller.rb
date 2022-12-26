# frozen_string_literal: true

class CupsController < ApplicationController
  before_action :find_cup

  def show
    @fantasy_team = @cup.fantasy_league.fantasy_teams.find_by!(user: Current.user)
    lineup_ids = @fantasy_team.lineups.where(week_id: @cup.cups_rounds.pluck(:week_id)).pluck(:id)
    @cups_pairs =
      Cups::Pair
      .joins(:cups_round)
      .where(cups_rounds: { cup_id: @cup })
      .where('home_lineup_id IN (?) OR visitor_lineup_id in (?)', lineup_ids, lineup_ids)
      .order(id: :desc)
  end

  private

  def find_cup
    @cup = Cup.find_by!(uuid: params[:id])
  end
end
