# frozen_string_literal: true

require 'csv'

desc 'Import Seria A schedule from Sports'
task sports_seria_a_schedule_import: :environment do
  NAME_MAPPER = {
    'Bologna' => 'BOL',
    'AC Milan' => 'MIL',
    'Empoli' => 'EMP',
    'Verona' => 'VER',
    'Frosinone' => 'FRO',
    'Napoli' => 'NAP',
    'Genoa' => 'GEN',
    'Fiorentina' => 'FIO',
    'Inter' => 'INT',
    'Monza' => 'MNZ',
    'Lecce' => 'LEC',
    'Lazio' => 'LAZ',
    'AS Roma' => 'ROM',
    'Salernitana' => 'SAL',
    'Sassuolo' => 'SAS',
    'Atalanta' => 'ATA',
    'Torino' => 'TOR',
    'Cagliari' => 'CAG',
    'Udinese' => 'UDI',
    'Juventus' => 'JUV'
  }.freeze

  api_key = Rails.application.credentials[:sports_api_key]
  http_service = HttpService::Client.new(url: 'https://v3.football.api-sports.io')

  result = http_service.get(
    path: 'fixtures',
    params: { league: 135, season: 2023 },
    headers: { 'x-rapidapi-key' => api_key, 'x-rapidapi-host' => 'v3.football.api-sports.io' }
  )

  CSV.open(Rails.root.join('db/data/seria_a_games_2024.csv'), 'w') do |csv|
    result['response'].each do |game|
      csv << [
        game.dig('fixture', 'id'),
        game.dig('fixture', 'date'),
        game.dig('league', 'round').split(' - ')[-1],
        NAME_MAPPER[game.dig('teams', 'home', 'name')],
        NAME_MAPPER[game.dig('teams', 'away', 'name')]
      ]
    end
  end
end
