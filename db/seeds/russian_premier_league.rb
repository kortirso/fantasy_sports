require 'csv'

league = League.create(
  sport_kind: 'football',
  name: { en: 'Russian Premier League', ru: 'Российская Премьер-Лига' },
  points_system: { W: 3, D: 1, L: 0 },
  background_url: 'leagues/rpl.webp'
)

league2024 = league.seasons.create(
  name: '2023/2024',
  active: true,
  members_count: 16,
  main_external_source: Sourceable::SPORTS
)

overall_league = league2024.all_fantasy_leagues.create leagueable: league2024, name: 'Overall', global: true

spartak = Team.create name: { en: 'Spartak', ru: 'Спартак' }, short_name: 'SPK'
orenburg = Team.create name: { en: 'Orenburg', ru: 'Оренбург' }, short_name: 'ORB'
rostov = Team.create name: { en: 'Rostov', ru: 'Ростов' }, short_name: 'ROS'
fakel = Team.create name: { en: 'Fakel', ru: 'Факел' }, short_name: 'FAK'
dinamo = Team.create name: { en: 'Dinamo', ru: 'Динамо' }, short_name: 'DIN'
krasnodar = Team.create name: { en: 'Krasnodar', ru: 'Краснодар' }, short_name: 'KRA'
lokomotiv = Team.create name: { en: 'Lokomotiv', ru: 'Локомотив' }, short_name: 'LOK'
rubin = Team.create name: { en: 'Rubin', ru: 'Рубин' }, short_name: 'RUB'
akhmat = Team.create name: { en: 'Akhmat', ru: 'Ахмат' }, short_name: 'AKH'
krylya_sovetov = Team.create name: { en: 'Krylya Sovetov', ru: 'Крылья Советов' }, short_name: 'KRS'
sochi = Team.create name: { en: 'Sochi', ru: 'Сочи' }, short_name: 'SOC'
baltika = Team.create name: { en: 'Baltika', ru: 'Балтика' }, short_name: 'BAL'
nizhny_novgorod = Team.create name: { en: 'Nizhny Novgorod', ru: 'Нижний Новгород' }, short_name: 'NVG'
zenit = Team.create name: { en: 'Zenit', ru: 'Зенит' }, short_name: 'ZEN'
ural = Team.create name: { en: 'Ural', ru: 'Урал' }, short_name: 'URA'
cska = Team.create name: { en: 'CSKA', ru: 'ЦСКА' }, short_name: 'CSK'

league2024.all_fantasy_leagues.create leagueable: spartak, name: 'Spartak', global: true
league2024.all_fantasy_leagues.create leagueable: orenburg, name: 'Orenburg', global: true
league2024.all_fantasy_leagues.create leagueable: rostov, name: 'Rostov', global: true
league2024.all_fantasy_leagues.create leagueable: fakel, name: 'Fakel', global: true
league2024.all_fantasy_leagues.create leagueable: dinamo, name: 'Dinamo', global: true
league2024.all_fantasy_leagues.create leagueable: krasnodar, name: 'Krasnodar', global: true
league2024.all_fantasy_leagues.create leagueable: lokomotiv, name: 'Lokomotiv', global: true
league2024.all_fantasy_leagues.create leagueable: rubin, name: 'Rubin', global: true
league2024.all_fantasy_leagues.create leagueable: akhmat, name: 'Akhmat', global: true
league2024.all_fantasy_leagues.create leagueable: krylya_sovetov, name: 'Krylya Sovetov', global: true
league2024.all_fantasy_leagues.create leagueable: sochi, name: 'Sochi', global: true
league2024.all_fantasy_leagues.create leagueable: baltika, name: 'Baltika', global: true
league2024.all_fantasy_leagues.create leagueable: nizhny_novgorod, name: 'Nizhny Novgorod', global: true
league2024.all_fantasy_leagues.create leagueable: zenit, name: 'Zenit', global: true
league2024.all_fantasy_leagues.create leagueable: ural, name: 'Ural', global: true
league2024.all_fantasy_leagues.create leagueable: cska, name: 'CSKA', global: true

spartak_league2024 = Seasons::Team.create team: spartak, season: league2024
orenburg_league2024 = Seasons::Team.create team: orenburg, season: league2024
rostov_league2024 = Seasons::Team.create team: rostov, season: league2024
fakel_league2024 = Seasons::Team.create team: fakel, season: league2024
dinamo_league2024 = Seasons::Team.create team: dinamo, season: league2024
krasnodar_league2024 = Seasons::Team.create team: krasnodar, season: league2024
lokomotiv_league2024 = Seasons::Team.create team: lokomotiv, season: league2024
rubin_league2024 = Seasons::Team.create team: rubin, season: league2024
akhmat_league2024 = Seasons::Team.create team: akhmat, season: league2024
krylya_sovetov_league2024 = Seasons::Team.create team: krylya_sovetov, season: league2024
sochi_league2024 = Seasons::Team.create team: sochi, season: league2024
baltika_league2024 = Seasons::Team.create team: baltika, season: league2024
nizhny_novgorod_league2024 = Seasons::Team.create team: nizhny_novgorod, season: league2024
zenit_league2024 = Seasons::Team.create team: zenit, season: league2024
ural_league2024 = Seasons::Team.create team: ural, season: league2024
cska_league2024 = Seasons::Team.create team: cska, season: league2024

rows = CSV.read(Rails.root.join('db/data/russian_premier_league_players_2024.csv'), col_sep: ';')

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
(2..30).each do |index|
  league2024.weeks.create position: index
end

games_rows = CSV.read(Rails.root.join('db/data/russian_premier_league_games_2024.csv'), col_sep: ',')
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
