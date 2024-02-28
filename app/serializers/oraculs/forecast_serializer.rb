# frozen_string_literal: true

module Oraculs
  class ForecastSerializer < ApplicationSerializer
    attributes :uuid

    attribute :owner do |_, params|
      params[:owner]
    end

    attribute :value do |object, params|
      if params[:owner] || !params[:forecastables].find { |e| e.id == object.forecastable_id }.predictable?
        object.value
      else
        []
      end
    end

    attribute :forecastable do |object, params|
      forecastable = params[:forecastables].find { |element| element.id == object.forecastable_id }
      {
        uuid: forecastable.uuid
      }
    end
  end
end
