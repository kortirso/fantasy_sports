require 'csv'

league = League.create(
  sport_kind: 'football',
  name: { en: 'Seria A', ru: 'Серия А' },
  points_system: { W: 3, D: 1, L: 0 },
  slug: 'seria_a'
)

league2024 = league.seasons.create(
  name: '2023/2024',
  active: true,
  members_count: 20,
  main_external_source: Sourceable::SPORTS
)

overall_league = league2024.all_fantasy_leagues.create leagueable: league2024, name: 'Overall', global: true

napoli = Team.create name: { en: 'Napoli', ru: 'Наполи' }, short_name: 'NAP'
inter = Team.create name: { en: 'Inter', ru: 'Интер' }, short_name: 'INT'
milan = Team.create name: { en: 'AC Milan', ru: 'Милан' }, short_name: 'MIL'
juventus = Team.create name: { en: 'Juventus', ru: 'Ювентус' }, short_name: 'JUV'
roma = Team.create name: { en: 'AS Roma', ru: 'Рома' }, short_name: 'ROM'
atalanta = Team.create name: { en: 'Atalanta', ru: 'Аталанта' }, short_name: 'ATA'
lazio = Team.create name: { en: 'Lazio', ru: 'Лацио' }, short_name: 'LAZ'
fiorentina = Team.create name: { en: 'Fiorentina', ru: 'Фиорентина' }, short_name: 'FIO'
torino = Team.create name: { en: 'Torino', ru: 'Торино' }, short_name: 'TOR'
bolognia = Team.create name: { en: 'Bologna', ru: 'Болонья' }, short_name: 'BOL'
sassuolo = Team.create name: { en: 'Sassuolo', ru: 'Сассуоло' }, short_name: 'SAS'
udineze = Team.create name: { en: 'Udineze', ru: 'Удинезе' }, short_name: 'UDI'
genoa = Team.create name: { en: 'Genoa', ru: 'Дженоа' }, short_name: 'GEN'
monza = Team.create name: { en: 'Monza', ru: 'Монца' }, short_name: 'MNZ'
salernitana = Team.create name: { en: 'Salernitana', ru: 'Салернитана' }, short_name: 'SAL'
empoli = Team.create name: { en: 'Empoli', ru: 'Эмполи' }, short_name: 'EMP'
verona = Team.create name: { en: 'Verona', ru: 'Верона' }, short_name: 'VER'
lecce = Team.create name: { en: 'Lecce', ru: 'Лечче' }, short_name: 'LEC'
cagliari = Team.create name: { en: 'Cagliari', ru: 'Кальяри' }, short_name: 'CAG'
frosinone = Team.create name: { en: 'Frosinone', ru: 'Фрозиноне' }, short_name: 'FRO'

league2024.all_fantasy_leagues.create leagueable: napoli, name: 'Napoli', global: true
league2024.all_fantasy_leagues.create leagueable: inter, name: 'Inter', global: true
league2024.all_fantasy_leagues.create leagueable: milan, name: 'AC Milan', global: true
league2024.all_fantasy_leagues.create leagueable: juventus, name: 'Juventus', global: true
league2024.all_fantasy_leagues.create leagueable: roma, name: 'AS Roma', global: true
league2024.all_fantasy_leagues.create leagueable: atalanta, name: 'Atalanta', global: true
league2024.all_fantasy_leagues.create leagueable: lazio, name: 'Lazio', global: true
league2024.all_fantasy_leagues.create leagueable: fiorentina, name: 'Fiorentina', global: true
league2024.all_fantasy_leagues.create leagueable: torino, name: 'Torino', global: true
league2024.all_fantasy_leagues.create leagueable: bolognia, name: 'Bologna', global: true
league2024.all_fantasy_leagues.create leagueable: sassuolo, name: 'Sassuolo', global: true
league2024.all_fantasy_leagues.create leagueable: udineze, name: 'Udineze', global: true
league2024.all_fantasy_leagues.create leagueable: genoa, name: 'Genoa', global: true
league2024.all_fantasy_leagues.create leagueable: monza, name: 'Monza', global: true
league2024.all_fantasy_leagues.create leagueable: salernitana, name: 'Salernitana', global: true
league2024.all_fantasy_leagues.create leagueable: empoli, name: 'Empoli', global: true
league2024.all_fantasy_leagues.create leagueable: verona, name: 'Verona', global: true
league2024.all_fantasy_leagues.create leagueable: lecce, name: 'Lecce', global: true
league2024.all_fantasy_leagues.create leagueable: cagliari, name: 'Cagliari', global: true
league2024.all_fantasy_leagues.create leagueable: frosinone, name: 'Frosinone', global: true

napoli_league2024 = Seasons::Team.create team: napoli, season: league2024
inter_league2024 = Seasons::Team.create team: inter, season: league2024
milan_league2024 = Seasons::Team.create team: milan, season: league2024
juventus_league2024 = Seasons::Team.create team: juventus, season: league2024
roma_league2024 = Seasons::Team.create team: roma, season: league2024
atalanta_league2024 = Seasons::Team.create team: atalanta, season: league2024
lazio_league2024 = Seasons::Team.create team: lazio, season: league2024
fiorentina_league2024 = Seasons::Team.create team: fiorentina, season: league2024
torino_league2024 = Seasons::Team.create team: torino, season: league2024
bolognia_league2024 = Seasons::Team.create team: bolognia, season: league2024
sassuolo_league2024 = Seasons::Team.create team: sassuolo, season: league2024
udineze_league2024 = Seasons::Team.create team: udineze, season: league2024
genoa_league2024 = Seasons::Team.create team: genoa, season: league2024
monza_league2024 = Seasons::Team.create team: monza, season: league2024
salernitana_league2024 = Seasons::Team.create team: salernitana, season: league2024
empoli_league2024 = Seasons::Team.create team: empoli, season: league2024
verona_league2024 = Seasons::Team.create team: verona, season: league2024
lecce_league2024 = Seasons::Team.create team: lecce, season: league2024
cagliari_league2024 = Seasons::Team.create team: cagliari, season: league2024
frosinone_league2024 = Seasons::Team.create team: frosinone, season: league2024

rows = CSV.read(Rails.root.join('db/data/seria_a_players_2024.csv'), col_sep: ';')

positions = {
  'G' => 'football_goalkeeper',
  'DEF' => 'football_defender',
  'MID' => 'football_midfielder',
  'FOR' => 'football_forward'
}.freeze

rows.each do |row|
  player = Player.create(
    position_kind: positions[row[8]],
    first_name: { en: row[1], ru: row[4] },
    last_name: { en: row[2], ru: row[5] },
    name: { en: "#{row[2]} #{row[1]}", ru: "#{row[5]} #{row[4]}" },
    nickname: { en: row[3], ru: row[6] }
  )
  players_season = Players::Season.create season: league2024, player: player
  Teams::Player.create(
    seasons_team: eval("#{row[0]}_league2024"),
    player: player,
    price_cents: row[9].to_i,
    shirt_number_string: row[7].to_s,
    players_season: players_season
  )
end

league2024.weeks.create position: 1, status: 'coming'
(2..38).each do |index|
  league2024.weeks.create position: index
end

games_rows = CSV.read(Rails.root.join('db/data/seria_a_games_2024.csv'), col_sep: ',')
seasons_teams = league2024.seasons_teams.map { |e| [e.team.short_name, e.id] }.to_h
weeks_positions = league2024.weeks.map { |e| [e.position, e.id] }.to_h

games_rows.each do |row|
  result = FantasySports::Container['forms.games.create'].call(
    params: {
      week_id: weeks_positions[row[2].to_i],
      season_id: Week.find(weeks_positions[row[2].to_i]).season_id,
      home_season_team_id: seasons_teams[row[3]],
      visitor_season_team_id: seasons_teams[row[4]],
      start_at: DateTime.parse(row[1])
    }
  )

  Games::ExternalSource.create(game_id: result[:result], source: Sourceable::SPORTS, external_id: row[0])
end

league2024.weeks.each do |week|
  week.update(deadline_at: week.games.minimum(:start_at) - 3.hours)
end
