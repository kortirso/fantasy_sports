# frozen_string_literal: true

module Sports
  class PositionSerializer < ApplicationSerializer
    attributes :id, :name, :total_amount

    attribute :min_game_amount, if: proc { |_, params| params_with_field?(params, 'min_game_amount') } do |object|
      object.min_game_amount
    end

    attribute :max_game_amount, if: proc { |_, params| params_with_field?(params, 'max_game_amount') } do |object|
      object.max_game_amount
    end
  end
end
