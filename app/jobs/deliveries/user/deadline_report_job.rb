# frozen_string_literal: true

module Deliveries
  module User
    class DeadlineReportJob < ApplicationJob
      queue_as :default

      def perform(delivery_service: UserDelivery)
        week_relation
          .each do |week|
            week.fantasy_teams.where(user_id: user_ids).each do |fantasy_team|
              delivery_service
                .with(user: fantasy_team.user, fantasy_team: fantasy_team, week: week)
                .deadline_report
                .deliver_later
            end
          end
      end

      private

      # rubocop: disable Metrics/AbcSize
      def week_relation
        Week
          .coming
          .where('deadline_at > ? AND deadline_at < ?', 1.day.after - 15.minutes, 1.day.after + 15.minutes)
          .or(
            Week
              .coming
              .where('deadline_at > ? AND deadline_at < ?', 1.hour.after - 15.minutes, 1.hour.after + 15.minutes)
          )
      end
      # rubocop: enable Metrics/AbcSize

      def user_ids
        Notification.where(notification_type: Notification::DEADLINE_DATA).pluck(:notifyable_id).uniq
      end
    end
  end
end
