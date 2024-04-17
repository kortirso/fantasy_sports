# frozen_string_literal: true

module Oraculs
  class CreateForm
    include Deps[validator: 'validators.oracul']

    def call(user:, oracul_place:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      result = ActiveRecord::Base.transaction do
        oracul = user.oraculs.create!(params.merge(oracul_place: oracul_place))
        connect_oracul_with_delphi_league(oracul, oracul_place)
        periodable_ids = create_lineups(oracul, oracul_place)
        create_forecasts(oracul, oracul_place, periodable_ids)
        oracul
      end

      { result: result }
    rescue ActiveRecord::RecordNotUnique => _e
      { errors: [I18n.t('services.oraculs.create.not_unique')] }
    end

    private

    def connect_oracul_with_delphi_league(oracul, oracul_place)
      oracul_place.oracul_leagues.general.find_by(name: 'Delphi').oracul_leagues_members.create!(oracul: oracul)
    end

    def create_lineups(oracul, oracul_place)
      ids, periodable_type =
        if oracul_place.season?
          [Week.future.where(season_id: oracul_place.placeable_id).pluck(:id), 'Week']
        else
          [Cups::Round.future.where(cup_id: oracul_place.placeable_id).pluck(:id), 'Cups::Round']
        end

      objects = ids.map do |id|
        {
          uuid: SecureRandom.uuid,
          oracul_id: oracul.id,
          periodable_id: id,
          periodable_type: periodable_type
        }
      end

      Oraculs::Lineup.upsert_all(objects) if objects.any?
      ids
    end

    def create_forecasts(oracul, oracul_place, periodable_ids)
      grouped_ids, forecastable_type = find_grouped_ids(oracul_place, periodable_ids)
      objects = []
      oracul.oraculs_lineups.hashable_pluck(:id, :periodable_id).each do |oraculs_lineup|
        grouped_ids[oraculs_lineup[:periodable_id]]&.each do |forecastable_id|
          objects << {
            uuid: SecureRandom.uuid,
            oraculs_lineup_id: oraculs_lineup[:id],
            forecastable_id: forecastable_id,
            forecastable_type: forecastable_type
          }
        end
      end

      Oraculs::Forecast.upsert_all(objects) if objects.any?
    end

    def find_grouped_ids(oracul_place, periodable_ids)
      if oracul_place.season?
        [
          Game
            .where(week_id: periodable_ids)
            .hashable_pluck(:id, :week_id)
            .group_by { |e| e[:week_id] }
            .transform_values { |values| values.pluck(:id) },
          'Game'
        ]
      else
        [
          Cups::Pair
            .where(cups_round_id: periodable_ids)
            .hashable_pluck(:id, :cups_round_id)
            .group_by { |e| e[:cups_round_id] }
            .transform_values { |values| values.pluck(:id) },
          'Cups::Pair'
        ]
      end
    end
  end
end
