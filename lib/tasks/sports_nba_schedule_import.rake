# frozen_string_literal: true

require 'csv'

desc 'Import NBA schedule from Sports'
task sports_nba_schedule_import: :environment do
  api_key = Rails.application.credentials[:sports_api_key]
  http_service = HttpService::Client.new(url: 'https://v2.nba.api-sports.io')

  result = http_service.get(
    path: 'games',
    params: { season: 2023 },
    headers: { 'x-rapidapi-key' => api_key, 'x-rapidapi-host' => 'v2.nba.api-sports.io' }
  )

  CSV.open(Rails.root.join('db/data/nba_games_sports_2024.csv'), 'w') do |csv|
    result['response'].each do |game|
      next unless game['stage'] == 2

      csv << [
        game['id'],
        game.dig('date', 'start'),
        game.dig('teams', 'home', 'code'),
        game.dig('teams', 'visitors', 'code')
      ]
    end
  end
end
