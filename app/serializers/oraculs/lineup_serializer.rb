# frozen_string_literal: true

module Oraculs
  class LineupSerializer < ApplicationSerializer
    set_id :id

    attribute :id, if: proc { |_, params| required_field?(params, 'id') }, &:id
    attribute :periodable_id, if: proc { |_, params| required_field?(params, 'periodable_id') }, &:periodable_id
    attribute :periodable_type, if: proc { |_, params| required_field?(params, 'periodable_type') }, &:periodable_type
    attribute :points, if: proc { |_, params| required_field?(params, 'points') }, &:points

    attribute :forecasts, if: proc { |_, params| required_field?(params, 'forecasts') } do |object, params|
      Oraculs::ForecastApiSerializer.new(
        object.oraculs_forecasts, params: {
          owner: params[:owner],
          forecastables: params[:owner] ? [] : object.periodable.games.to_a,
          include_fields: %w[id owner forecastable_id value]
        }
      ).serializable_hash
    end

    attribute :lineups_data, if: proc { |_, params| required_field?(params, 'lineups_data') } do |_, params|
      data = params[:periodable].oraculs_lineups.pluck(:points)
      {
        max: data.max,
        avg: data.any? ? (data.sum / data.size).round(1) : 0
      }
    end
  end
end
