league = League.create(sport_kind: 'football', name: { en: 'English Premier League', ru: 'Английская Премьер-Лига' })

league2024 = league.seasons.create name: '2023/2024', active: true

overall_league = league2024.all_fantasy_leagues.create leagueable: league2024, name: 'Overall', global: true

tottenham = Team.create name: { en: 'Tottenham Hotspur', ru: 'Тоттенхэм' }, short_name: 'TOT'
arsenal = Team.create name: { en: 'Arsenal', ru: 'Арсенал' }, short_name: 'ARS'
manchester_city = Team.create name: { en: 'Manchester City', ru: 'Манчестер Сити' }, short_name: 'MCI'
liverpool = Team.create name: { en: 'Liverpool', ru: 'Ливерпуль' }, short_name: 'LIV'
aston_villa = Team.create name: { en: 'Aston Villa', ru: 'Астон Вилла' }, short_name: 'AVL'
newcastle = Team.create name: { en: 'Newcastle United', ru: 'Ньюкасл Юнайтед' }, short_name: 'NEW'
brighton = Team.create name: { en: 'Brighton & Hove Albion', ru: 'Брайтон' }, short_name: 'BHA'
manchester = Team.create name: { en: 'Manchester United', ru: 'Манчестер Юнайтед' }, short_name: 'MAN'
west_ham = Team.create name: { en: 'West Ham United', ru: 'Вест Хэм Юнайтед' }, short_name: 'WHU'
brentford = Team.create name: { en: 'Brentford', ru: 'Брентфорд' }, short_name: 'BRE'
chelsea = Team.create name: { en: 'Chelsea', ru: 'Челси' }, short_name: 'CHE'
wolvs = Team.create name: { en: 'Wolverhampton Wanderers', ru: 'Вулверхэмптон' }, short_name: 'WOL'
crystal_palace = Team.create name: { en: 'Crystal Palace', ru: 'Кристал Пэлас' }, short_name: 'CRY'
fulham = Team.create name: { en: 'Fulham', ru: 'Фулхэм' }, short_name: 'FUL'
everton = Team.create name: { en: 'Everton', ru: 'Эвертон' }, short_name: 'EVE'
nottingham = Team.create name: { en: 'Nottingham Forest', ru: 'Ноттингем Форест' }, short_name: 'NOT'
bournemouth = Team.create name: { en: 'Bournemouth', ru: 'Борнмут' }, short_name: 'BOR'
luton = Team.create name: { en: 'Luton Town', ru: 'Лутон Таун' }, short_name: 'LUT'
burnley = Team.create name: { en: 'Burnley', ru: 'Бёрнли' }, short_name: 'BUR'
sheffield = Team.create name: { en: 'Sheffield United', ru: 'Шеффилд Юнайтед' }, short_name: 'SHE'

league2024.all_fantasy_leagues.create leagueable: tottenham, name: 'Tottenham', global: true
league2024.all_fantasy_leagues.create leagueable: arsenal, name: 'Arsenal', global: true
league2024.all_fantasy_leagues.create leagueable: manchester_city, name: 'Man City', global: true
league2024.all_fantasy_leagues.create leagueable: liverpool, name: 'Liverpool', global: true
league2024.all_fantasy_leagues.create leagueable: aston_villa, name: 'Aston Villa', global: true
league2024.all_fantasy_leagues.create leagueable: newcastle, name: 'Newcastle', global: true
league2024.all_fantasy_leagues.create leagueable: brighton, name: 'Brighton', global: true
league2024.all_fantasy_leagues.create leagueable: manchester, name: 'Man United', global: true
league2024.all_fantasy_leagues.create leagueable: west_ham, name: 'West Ham', global: true
league2024.all_fantasy_leagues.create leagueable: brentford, name: 'Brentford', global: true
league2024.all_fantasy_leagues.create leagueable: chelsea, name: 'Chelsea', global: true
league2024.all_fantasy_leagues.create leagueable: wolvs, name: 'Wolves', global: true
league2024.all_fantasy_leagues.create leagueable: crystal_palace, name: 'Crystal Palace', global: true
league2024.all_fantasy_leagues.create leagueable: fulham, name: 'Fulham', global: true
league2024.all_fantasy_leagues.create leagueable: everton, name: 'Everton', global: true
league2024.all_fantasy_leagues.create leagueable: nottingham, name: 'Nottingham', global: true
league2024.all_fantasy_leagues.create leagueable: bournemouth, name: 'Bournemouth', global: true
league2024.all_fantasy_leagues.create leagueable: luton, name: 'Luton', global: true
league2024.all_fantasy_leagues.create leagueable: burnley, name: 'Burnley', global: true
league2024.all_fantasy_leagues.create leagueable: sheffield, name: 'Sheffield', global: true

tottenham_league2024 = Seasons::Team.create team: tottenham, season: league2024
arsenal_league2024 = Seasons::Team.create team: arsenal, season: league2024
manchester_city_league2024 = Seasons::Team.create team: manchester_city, season: league2024
liverpool_league2024 = Seasons::Team.create team: liverpool, season: league2024
aston_villa_league2024 = Seasons::Team.create team: aston_villa, season: league2024
newcastle_league2024 = Seasons::Team.create team: newcastle, season: league2024
brighton_league2024 = Seasons::Team.create team: brighton, season: league2024
manchester_league2024 = Seasons::Team.create team: manchester, season: league2024
west_ham_league2024 = Seasons::Team.create team: west_ham, season: league2024
brentford_league2024 = Seasons::Team.create team: brentford, season: league2024
chelsea_league2024 = Seasons::Team.create team: chelsea, season: league2024
wolvs_league2024 = Seasons::Team.create team: wolvs, season: league2024
crystal_palace_league2024 = Seasons::Team.create team: crystal_palace, season: league2024
fulham_league2024 = Seasons::Team.create team: fulham, season: league2024
everton_league2024 = Seasons::Team.create team: everton, season: league2024
nottingham_league2024 = Seasons::Team.create team: nottingham, season: league2024
bournemouth_league2024 = Seasons::Team.create team: bournemouth, season: league2024
luton_league2024 = Seasons::Team.create team: luton, season: league2024
burnley_league2024 = Seasons::Team.create team: burnley, season: league2024
sheffield_league2024 = Seasons::Team.create team: sheffield, season: league2024

rows = CSV.read(Rails.root.join('db/data/premier_league_players_2024.csv'), col_sep: ';')

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

games_rows = CSV.read(Rails.root.join('db/data/premier_league_games_2024.csv'), col_sep: ',')
seasons_teams = league2024.seasons_teams.map { |e| [e.team.short_name, e.id] }.to_h
weeks_positions = league2024.weeks.map { |e| [e.position, e.id] }.to_h

games_rows.each do |row|
  Games::CreateService.call(
    params: {
      week_id: weeks_positions[row[2].to_i],
      home_season_team_id: seasons_teams[row[3]],
      visitor_season_team_id: seasons_teams[row[4]],
      source: Sourceable::SPORTS,
      external_id: row[0],
      start_at: DateTime.parse(row[1])
    }
  )
end

league2024.weeks.each do |week|
  week.update(deadline_at: week.games.minimum(:start_at) - 3.hours)
end
