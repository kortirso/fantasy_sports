# frozen_string_literal: true

class AchievementsController < ApplicationController
  SUMMARY_ACHIEVEMENTS_RENDER_SIZE = 5

  before_action :find_achievements, only: %i[index]
  before_action :find_unreceived_achievements, only: %i[index]

  def index
    render json: {
      received: AchievementSerializer.new(@achievements).serializable_hash,
      unreceived: AchievementSerializer.new(@unreceived_achievements).serializable_hash,
      achievements_points: @achievements_points
    }, status: :ok
  end

  private

  def find_achievements
    base_achievements
    filter_achievements
    group_achievements
    @achievements = @achievements.first(SUMMARY_ACHIEVEMENTS_RENDER_SIZE) if params[:group_uuid].blank?
  end

  def base_achievements
    @achievements = Current.user.kudos_users_achievements.order(rank: :desc)
    @achievements_points = @achievements.sum(:points)
  end

  def filter_achievements
    return if params[:group_uuid].blank?

    group = Kudos::AchievementGroup.find_by(uuid: params[:group_uuid])
    return if group.nil?

    @achievements =
      @achievements
        .joins(kudos_achievement: :kudos_achievement_group)
        .where(kudos_achievement_groups: { id: group.with_children_groups })
  end

  def group_achievements
    @achievements =
      @achievements
      .group_by { |users_achievement| users_achievement.kudos_achievement.award_name }
      .map { |_key, values| values.first }
  end

  def find_unreceived_achievements
    @unreceived_achievements =
      Kudos::Achievement
        .where.not(id: received_achievements_ids)
        .order(award_name: :asc, rank: :asc)

    @unreceived_achievements =
      if params[:group_uuid].present?
        @unreceived_achievements
          .joins(:kudos_achievement_group)
          .where(kudos_achievement_groups: { uuid: params[:group_uuid] })
      else
        @unreceived_achievements.first(SUMMARY_ACHIEVEMENTS_RENDER_SIZE - @achievements.size)
      end
  end

  def received_achievements_ids
    Current.user.kudos_users_achievements.select(:kudos_achievement_id)
  end
end
