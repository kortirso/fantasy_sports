# frozen_string_literal: true

class AchievementsController < ApplicationController
  before_action :find_achievements

  def index
    render json: { achievements: AchievementSerializer.new(@achievements).serializable_hash }, status: :ok
  end

  private

  def find_achievements
    @achievements = Current.user.kudos_users_achievements.order(updated_at: :desc)
    if params[:group_uuid]
      @achievements =
        @achievements
        .joins(:kudos_achievement)
        .where(
          kudos_achievement: {
            kudos_achievement_group: Kudos::AchievementGroup.find_by!(uuid: params[:group_uuid]).with_children_groups
          }
        )
    else
      @achievements = @achievements.first(5)
    end
  end
end
