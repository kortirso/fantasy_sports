# frozen_string_literal: true

class AchievementGroupsController < ApplicationController
  def index
    render json: { achievement_groups: achievement_groups }, status: :ok
  end

  private

  def achievement_groups
    Rails.cache.fetch(
      'achievement_groups_index_v1',
      expires_in: 24.hours,
      race_condition_ttl: 10.seconds
    ) do
      AchievementGroupSerializer.new(
        Kudos::AchievementGroup.where(parent_id: nil).order(position: :asc)
      ).serializable_hash
    end
  end
end
