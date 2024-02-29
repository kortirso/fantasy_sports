# frozen_string_literal: true

class OraculsController < ApplicationController
  before_action :find_oracul
  before_action :find_periodable
  before_action :find_oraculs_lineup
  before_action :calculate_lineups_data

  def show; end

  private

  def find_oracul
    @oracul = Oracul.find_by!(uuid: params[:id])
  end

  def find_periodable
    placeable = @oracul.oracul_place.placeable
    relation = @oracul.oracul_place.season? ? placeable.weeks : placeable.cups_rounds
    @periodable = params[:week] ? relation.find_by!(position: params[:week]) : (relation.active.first || relation.first)
  end

  def find_oraculs_lineup
    @oraculs_lineup = @oracul.oraculs_lineups.find_by(periodable: @periodable)
  end

  def calculate_lineups_data
    return if @periodable.nil?

    @lineups_data = @periodable.oraculs_lineups.pluck(:points)
  end
end
