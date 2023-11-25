# frozen_string_literal: true

require 'csv'

LA_LIGA_NAME_MAPPER = {
  'Alaves' => 'ALA',
  'Almeria' => 'ALM',
  'Athletic Club' => 'ATH',
  'Atletico Madrid' => 'ATL',
  'Barcelona' => 'BAR',
  'Real Betis' => 'BET',
  'Valencia' => 'VAL',
  'Villarreal' => 'VIL',
  'Granada CF' => 'GRA',
  'Girona' => 'GIR',
  'Cadiz' => 'CAD',
  'Las Palmas' => 'LAS',
  'Mallorca' => 'MAL',
  'Osasuna' => 'OSA',
  'Rayo Vallecano' => 'RAY',
  'Real Madrid' => 'RLM',
  'Real Sociedad' => 'RLS',
  'Celta Vigo' => 'CEL',
  'Getafe' => 'GET',
  'Sevilla' => 'SEV'
}.freeze

desc 'Import La Liga schedule from Sports'
task sports_la_liga_schedule_import: :environment do
  api_key = Rails.application.credentials[:sports_api_key]
  http_service = HttpService::Client.new(url: 'https://v3.football.api-sports.io')

  result = http_service.get(
    path: 'fixtures',
    params: { league: 140, season: 2023 },
    headers: { 'x-rapidapi-key' => api_key, 'x-rapidapi-host' => 'v3.football.api-sports.io' }
  )

  CSV.open(Rails.root.join('db/data/la_liga_games_2024.csv'), 'w') do |csv|
    result['response'].each do |game|
      csv << [
        game.dig('fixture', 'id'),
        game.dig('fixture', 'date'),
        game.dig('league', 'round').split(' - ')[-1],
        LA_LIGA_NAME_MAPPER[game.dig('teams', 'home', 'name')],
        LA_LIGA_NAME_MAPPER[game.dig('teams', 'away', 'name')]
      ]
    end
  end
end
