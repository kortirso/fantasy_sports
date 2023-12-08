# frozen_string_literal: true

require 'csv'

BUNDESLIGA_NAME_MAPPER = {
  'Eintracht Frankfurt' => 'EIN',
  'FC Augsburg' => 'AUG',
  'Bayern Munich' => 'BRN',
  'Bayer Leverkusen' => 'BAY',
  'Borussia Dortmund' => 'BRD',
  'Borussia Monchengladbach' => 'BRM',
  'VfL BOCHUM' => 'BCH',
  'Werder Bremen' => 'WER',
  'VfL Wolfsburg' => 'WLF',
  'SV Darmstadt 98' => 'DRM',
  'FC Koln' => 'KLN',
  'FSV Mainz 05' => 'MAI',
  'RB Leipzig' => 'LPZ',
  'Union Berlin' => 'UNI',
  'SC Freiburg' => 'FRE',
  'FC Heidenheim' => 'HEI',
  '1899 Hoffenheim' => 'HOF',
  'VfB Stuttgart' => 'STG'
}.freeze

desc 'Import Bundesliga schedule from Sports'
task sports_bundesliga_schedule_import: :environment do
  api_key = Rails.application.credentials[:sports_api_key]
  http_service = HttpService::Client.new(url: 'https://v3.football.api-sports.io')

  result = http_service.get(
    path: 'fixtures',
    params: { league: 78, season: 2023 },
    headers: { 'x-rapidapi-key' => api_key, 'x-rapidapi-host' => 'v3.football.api-sports.io' }
  )

  CSV.open(Rails.root.join('db/data/bundesliga_games_2024.csv'), 'w') do |csv|
    result['response'].each do |game|
      csv << [
        game.dig('fixture', 'id'),
        game.dig('fixture', 'date'),
        game.dig('league', 'round').split(' - ')[-1],
        BUNDESLIGA_NAME_MAPPER[game.dig('teams', 'home', 'name')],
        BUNDESLIGA_NAME_MAPPER[game.dig('teams', 'away', 'name')]
      ]
    end
  end
end
