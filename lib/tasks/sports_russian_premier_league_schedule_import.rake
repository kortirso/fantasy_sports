# frozen_string_literal: true

require 'csv'

RUSSIAN_PREMIER_LEAGUE_NAME_MAPPER = {
  'Spartak Moscow' => 'SPK',
  'Orenburg' => 'ORB',
  'FC Rostov' => 'ROS',
  'Fakel Voronezh' => 'FAK',
  'Dinamo Moscow' => 'DIN',
  'Krasnodar' => 'KRA',
  'Lokomotiv Moscow' => 'LOK',
  'Rubin' => 'RUB',
  'Akhmat Grozny' => 'AKH',
  'Krylya Sovetov' => 'KRS',
  'PFC Sochi' => 'SOC',
  'Baltika' => 'BAL',
  'Nizhny Novgorod' => 'NVG',
  'Zenit Saint Petersburg' => 'ZEN',
  'Ural' => 'URA',
  'CSKA Moscow' => 'CSK'
}.freeze

desc 'Import Russian Premier League schedule from Sports'
task sports_russian_premier_league_schedule_import: :environment do
  api_key = Rails.application.credentials[:sports_api_key]
  http_service = HttpService::Client.new(url: 'https://v3.football.api-sports.io')

  result = http_service.get(
    path: 'fixtures',
    params: { league: 235, season: 2023 },
    headers: { 'x-rapidapi-key' => api_key, 'x-rapidapi-host' => 'v3.football.api-sports.io' }
  )

  CSV.open(Rails.root.join('db/data/russian_premier_league_games_2024.csv'), 'w') do |csv|
    result['response'].each do |game|
      csv << [
        game.dig('fixture', 'id'),
        game.dig('fixture', 'date'),
        game.dig('league', 'round').split(' - ')[-1],
        RUSSIAN_PREMIER_LEAGUE_NAME_MAPPER[game.dig('teams', 'home', 'name')],
        RUSSIAN_PREMIER_LEAGUE_NAME_MAPPER[game.dig('teams', 'away', 'name')]
      ]
    end
  end
end
