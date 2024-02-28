# frozen_string_literal: true

class OraculPlacesController < ApplicationController
  before_action :find_leagues
  before_action :find_oracul_places
  before_action :find_user_oraculs

  def show; end

  private

  def find_leagues
    @leagues = League.hashable_pluck(:id, :name, :sport_kind)
  end

  def find_oracul_places
    @oracul_places = OraculPlace.active.load
  end

  def find_user_oraculs
    @user_oraculs = Current.user.oraculs.hashable_pluck(:uuid, :name, :oracul_place_id)
  end
end
