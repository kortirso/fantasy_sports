# frozen_string_literal: true

require 'csv'

PREMIER_LEAGUE_NAME_MAPPER = {
  'Tottenham' => 'TOT',
  'Arsenal' => 'ARS',
  'Manchester City' => 'MCI',
  'Liverpool' => 'LIV',
  'Aston Villa' => 'AVL',
  'Newcastle' => 'NEW',
  'Brighton' => 'BHA',
  'Manchester United' => 'MAN',
  'West Ham' => 'WHU',
  'Brentford' => 'BRE',
  'Chelsea' => 'CHE',
  'Wolves' => 'WOL',
  'Crystal Palace' => 'CRY',
  'Fulham' => 'FUL',
  'Everton' => 'EVE',
  'Nottingham Forest' => 'NOT',
  'Bournemouth' => 'BOR',
  'Luton' => 'LUT',
  'Burnley' => 'BUR',
  'Sheffield Utd' => 'SHE'
}.freeze

desc 'Import Premier League schedule from Sports'
task sports_premier_league_schedule_import: :environment do
  api_key = Rails.application.credentials[:sports_api_key]
  http_service = HttpService::Client.new(url: 'https://v3.football.api-sports.io')
  result = http_service.get(
    path: 'fixtures',
    params: { league: 39, season: 2023 },
    headers: { 'x-rapidapi-key' => api_key, 'x-rapidapi-host' => 'v3.football.api-sports.io' }
  )

  CSV.open(Rails.root.join('db/data/premier_league_games_2024.csv'), 'w') do |csv|
    result['response'].each do |game|
      csv << [
        game.dig('fixture', 'id'),
        game.dig('fixture', 'date'),
        game.dig('league', 'round').split(' - ')[-1],
        PREMIER_LEAGUE_NAME_MAPPER[game.dig('teams', 'home', 'name')],
        PREMIER_LEAGUE_NAME_MAPPER[game.dig('teams', 'away', 'name')]
      ]
    end
  end
end
