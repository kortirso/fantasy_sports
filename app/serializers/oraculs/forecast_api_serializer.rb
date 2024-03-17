# frozen_string_literal: true

module Oraculs
  class ForecastApiSerializer < ApplicationSerializer
    attributes :id

    attribute :id, if: proc { |_, params| required_field?(params, 'id') }, &:id
    attribute :forecastable_id, if: proc { |_, params| required_field?(params, 'forecastable_id') }, &:forecastable_id

    attribute :owner do |_, params|
      params[:owner]
    end

    attribute :value, if: proc { |_, params| required_field?(params, 'value') } do |object, params|
      if params[:owner] || !params[:forecastables].find { |item| item.id == object.forecastable_id }.predictable?
        object.value
      else
        []
      end
    end
  end
end
