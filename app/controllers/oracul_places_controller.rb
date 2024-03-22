# frozen_string_literal: true

class OraculPlacesController < ApplicationController
  before_action :find_leagues
  before_action :find_oracul_places
  before_action :find_oracul_places_leagues
  before_action :find_user_oraculs

  def show; end

  private

  def find_leagues
    @leagues =
      Rails.cache.fetch('oracul_places_show_leagues_v2', expires_in: 24.hours, race_condition_ttl: 10.seconds) do
        League.hashable_pluck(:id, :slug, :sport_kind)
      end
  end

  def find_oracul_places
    @oracul_places = OraculPlace.active.hashable_pluck(:id, :uuid, :name, :placeable_id, :placeable_type, :created_at)
  end

  def find_oracul_places_leagues
    @oracul_places_leagues =
      Rails.cache.fetch(
        ['oracul_places_show_v1', @oracul_places.max_by { |oracul_place| oracul_place[:created_at] }],
        expires_in: 24.hours,
        race_condition_ttl: 10.seconds
      ) do
        seasons = Season.pluck(:id, :league_id).to_h
        cups = Cup.pluck(:id, :league_id).to_h

        @oracul_places.to_h { |oracul_place|
          relation =
            case oracul_place[:placeable_type]
            when 'Season' then seasons
            when 'Cup' then cups
            end
          [
            oracul_place[:id],
            relation[oracul_place[:placeable_id]]
          ]
        }
      end
  end

  def find_user_oraculs
    @user_oraculs = Current.user.oraculs.hashable_pluck(:uuid, :name, :oracul_place_id)
  end
end
