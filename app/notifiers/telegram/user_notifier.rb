# frozen_string_literal: true

module Telegram
  class UserNotifier < TelegramNotifier
    def deadline_report
      notification(
        chat_id: user.identities.telegram.first.uid,
        body: insights_report_payload.call(fantasy_team: fantasy_team, week: week, locale: user.locale)
      )
    end

    private

    def user = params[:user]
    def fantasy_team = params[:fantasy_team]
    def week = params[:week]
    def insights_report_payload = FantasySports::Container['notifiers.telegram.user.deadline_report_payload']
  end
end
