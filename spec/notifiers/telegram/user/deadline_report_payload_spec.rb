# frozen_string_literal: true

describe Telegram::User::DeadlineReportPayload, type: :service do
  subject(:service_call) { described_class.new.call(fantasy_team: fantasy_team, week: week, locale: locale) }

  let!(:fantasy_team) { create :fantasy_team }
  let!(:week) { create :week, deadline_at: 1.day.after }

  context 'for en locale' do
    let(:locale) { 'en' }

    it 'generates payload', :aggregate_failures do
      expect(service_call).to include("Deadline is coming for your fantasy team #{fantasy_team.name}")
      expect(service_call).to include('Time left is - 23h 59m')
      expect(service_call).to(
        include(
          "For making transfers please visit http://localhost:5000/fantasy_teams/#{fantasy_team.uuid}/transfers"
        )
      )
    end
  end

  context 'for ru locale' do
    let(:locale) { 'ru' }

    it 'generates payload', :aggregate_failures do
      expect(service_call).to include("Подходит дедлайн для вашей фэнтези команды #{fantasy_team.name}")
      expect(service_call).to include('До дедлайна осталось 23h 59m')
      expect(service_call).to(
        include(
          "Для выполнения трансферов перейдите по ссылке http://localhost:5000/ru/fantasy_teams/#{fantasy_team.uuid}/transfers"
        )
      )
    end
  end
end
