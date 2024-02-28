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
    @periodable = @oracul.oracul_place.season? ? find_week : nil
  end

  def find_oraculs_lineup
    @oraculs_lineup = @oracul.oraculs_lineups.find_by(periodable: @periodable)
  end

  def calculate_lineups_data
    return if @periodable.nil?

    @lineups_data = @periodable.oraculs_lineups.pluck(:points)
  end

  def find_week
    weeks = @oracul.oracul_place.placeable.weeks
    params[:week] ? weeks.find_by!(position: params[:week]) : (weeks.active.first || weeks.first)
  end
end
