# frozen_string_literal: true

class SchedulerJob < ApplicationJob
  queue_as :default

  def perform
    start_seasons
    change_weeks
    import_games
  end

  private

  def start_seasons
    # start season with updating first week as coming
    Season.in_progress.where('start_at < ? AND start_at > ?', 15.minutes.after, 15.minutes.ago).each do |season|
      season.weeks.inactive.order(position: :asc).first.update(status: Week::COMING)
    end
  end

  def change_weeks
    Week.coming.where('deadline_at < ? AND deadline_at > ?', 15.minutes.after, 15.minutes.ago).ids.each do |week_id|
      Weeks::ChangeService.call(week_id: week_id)
    end
  end

  def import_games
    refresh_achievements = false
    # fetch game statistics 1 time, 3 hours after game start and no points before
    # game started at 5:00 will be fetched at 8:00
    # game started at 5:30 will be fetched at 8:30
    Season.in_progress.hashable_pluck(:id, :main_external_source).each do |season|
      game_ids =
        Game
          .joins(:week)
          .where(weeks: { status: Week::ACTIVE, season_id: season[:id] })
          .where(start_at: ...165.minutes.ago)
          .where(points: [])
          .pluck(:id)
      next if game_ids.blank?

      Games::ImportJob.perform_later(game_ids: game_ids, main_external_source: season[:main_external_source])
      refresh_achievements = true
    end
    Achievements::RefreshAfterGameJob.perform_later if refresh_achievements
  end
end
