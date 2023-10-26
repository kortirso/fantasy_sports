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
    Season.active.where('start_at < ? AND start_at > ?', 15.minutes.after, 15.minutes.ago).each do |season|
      season.weeks.inactive.order(position: :asc).first.update(status: Week::COMING)
    end
  end

  def change_weeks
    Week.coming.where('deadline_at < ? AND deadline_at > ?', 15.minutes.after, 15.minutes.ago).ids.each do |week_id|
      Weeks::ChangeService.call(week_id: week_id)
    end
  end

  def import_games
    # fetch game statistics 1 time, 3-3.5 hours after game start and no points before
    # game started at 5:00 will be fetched at 8:00
    # game started at 5:30 will be fetched at 9:00
    Season.active.pluck(:id).each do |season_id|
      game_ids =
        Game
          .joins(:week)
          .where(weeks: { status: Week::ACTIVE, season_id: season_id })
          .where('start_at < ?', 165.minutes.ago)
          .where(points: [])
          .pluck(:id)

      Games::ImportJob.perform_later(game_ids: game_ids) if game_ids.any?
    end
  end
end
