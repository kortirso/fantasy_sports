# frozen_string_literal: true

module Telegram
  module User
    class DeadlineReportPayload
      include Deps[time_representer: 'services.converters.seconds_to_text']

      def call(fantasy_team:, week:, locale:)
        I18n.with_locale(locale) do
          [
            I18n.t(
              'notifiers.telegram.user.deadline_report_payload.title',
              value: fantasy_team.name
            ),
            I18n.t(
              'notifiers.telegram.user.deadline_report_payload.time_left',
              value: time_before_deadline(week)
            ),
            I18n.t(
              'notifiers.telegram.user.deadline_report_payload.link',
              value: Rails.application.routes.url_helpers.fantasy_team_transfers_url(
                fantasy_team_id: fantasy_team.uuid,
                locale: locale.to_sym == I18n.default_locale ? nil : locale
              )
            )
          ].join("\n")
        end
      end

      private

      def time_before_deadline(week)
        time_representer.call(value: (week.deadline_at - DateTime.now).to_i)
      end
    end
  end
end
