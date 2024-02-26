# frozen_string_literal: true

class OraculPlacesController < ApplicationController
  before_action :find_leagues
  before_action :find_oracul_places

  def show; end

  private

  def find_leagues
    @leagues = League.hashable_pluck(:id, :name, :sport_kind)
  end

  def find_oracul_places
    @oracul_places = OraculPlace.active.load
  end
end
