# frozen_string_literal: true

class AchievementGroupsController < ApplicationController
  include Cacheable

  before_action :find_achievement_groups, only: %i[index]

  def index
    render json: { achievement_groups: achievement_groups_json_response }, status: :ok
  end

  private

  def find_achievement_groups
    @achievement_groups = Kudos::AchievementGroup.where(parent_id: nil).order(position: :asc)
  end

  def achievement_groups_json_response
    cached_response(payload: @achievement_groups, name: :achievement_groups, version: :v1) do
      AchievementGroupSerializer.new(@achievement_groups).serializable_hash
    end
  end
end
