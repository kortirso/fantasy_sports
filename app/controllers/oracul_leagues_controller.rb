# frozen_string_literal: true

class OraculLeaguesController < ApplicationController
  before_action :find_oracul_league
  before_action :find_oracul
  before_action :find_oracul_league_members

  def show; end

  private

  def find_oracul_league
    @oracul_league = OraculLeague.find_by!(uuid: params[:id])
  end

  def find_oracul
    @oracul = @oracul_league.oraculs.find_by(user: Current.user)
  end

  def find_oracul_league_members
    @oracul_leagues_members =
      @oracul_league
        .oraculs
        .order(points: :desc)
        .hashable_pluck(:id, :uuid, :name, :points)
        .first(50)
  end
end
