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
    # fetch game statistics 2 times, after 2-2.5 hours and 3-3.5 hours after game start
    # game started at 5:00 will be fetched at 7:00 and 8:00
    # game started at 5:30 will be fetched at 8:00 and 9:00
    Game
      .joins(:week)
      .where(weeks: { status: Week::ACTIVE })
      .where('start_at > ? AND start_at < ?', 100.minutes.ago, 220.minutes.after)
      .pluck(:id)
      .each do |game_id|
        Games::ImportJob.perform_later(game_id: game_id)
      end
  end
end
