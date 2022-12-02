# frozen_string_literal: true

class AchievementGroupSerializer < ApplicationSerializer
  attributes :uuid, :name

  attribute :children do |object|
    AchievementGroupSerializer.new(object.children.order(position: :asc)).serializable_hash
  end
end
