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
    # fetch game statistics 2 times, after 120.minutes and 180.minutes after game start
    Game
      .joins(:week)
      .where(weeks: { status: Week::ACTIVE })
      .where('start_at < ? AND start_at > ?', 200.minutes.after, 90.minutes.ago)
      .pluck(:id)
      .each do |game_id|
        Games::ImportJob.perform_later(game_id: game_id)
      end
  end
end
