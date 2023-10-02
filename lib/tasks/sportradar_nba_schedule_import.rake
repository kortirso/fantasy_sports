# frozen_string_literal: true

desc 'Import NBA schedule from SportRadar'
task sportradar_nba_schedule_import: :environment do
  api_key = Rails.application.credentials[:sportradar_api_key]
  http_service = HttpService::Client.new(url: 'https://api.sportradar.com')
  http_service.get(path: "nba/trial/v8/en/games/2024/REG/schedule.json?api_key=#{api_key}")
end
