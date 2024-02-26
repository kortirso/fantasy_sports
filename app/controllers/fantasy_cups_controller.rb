# frozen_string_literal: true

class FantasyCupsController < ApplicationController
  before_action :find_cup, only: %i[show]

  def show
    @fantasy_team = @cup.fantasy_league.fantasy_teams.find_by!(user: Current.user)
    lineup_ids = @fantasy_team.lineups.where(week_id: @cup.fantasy_cups_rounds.pluck(:week_id)).pluck(:id)
    @cups_pairs =
      FantasyCups::Pair
        .joins(:fantasy_cups_round)
        .where(fantasy_cups_rounds: { cup_id: @cup })
        .where('home_lineup_id IN (?) OR visitor_lineup_id in (?)', lineup_ids, lineup_ids)
        .order(id: :desc)
        .load
  end

  private

  def find_cup
    @cup = FantasyCup.find_by!(uuid: params[:id])
  end
end
