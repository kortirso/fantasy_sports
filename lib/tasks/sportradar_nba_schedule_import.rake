# frozen_string_literal: true

require 'csv'

desc 'Import NBA schedule from SportRadar'
task sportradar_nba_schedule_import: :environment do
  api_key = Rails.application.credentials[:sportradar_api_key]
  http_service = HttpService::Client.new(url: 'https://api.sportradar.com')
  result = http_service.get(path: "nba/trial/v8/en/games/2023/REG/schedule.json?api_key=#{api_key}")

  CSV.open(Rails.root.join('db/data/nba_games_2024.csv'), 'w') do |csv|
    result['games'].each do |game|
      csv << [
        game['id'],
        game['scheduled'],
        game['home']['alias'],
        game['away']['alias']
      ]
    end
  end
end
