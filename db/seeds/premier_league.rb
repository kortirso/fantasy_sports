league = League.create(sport_kind: 'football', name: { en: 'Premier Liga', ru: 'Премьер-Лига' })

league2024 = league.seasons.create name: '2023/2024', active: true, start_at: DateTime.new(2023, 11, 8, 0, 0, 0)

overall_league = league2024.all_fantasy_leagues.create leagueable: league2024, name: 'Overall', global: true

tottenham = Team.create name: { en: 'Tottenham Hotspur', ru: 'Тоттенхэм' }, short_name: 'TOT'
arsenal = Team.create name: { en: 'Arsenal', ru: 'Арсенал' }, short_name: 'ARS'
manchester_city = Team.create name: { en: 'Manchester City', ru: 'Манчестер Сити' }, short_name: 'MCI'
liverpool = Team.create name: { en: 'Liverpool', ru: 'Ливерпуль' }, short_name: 'LIV'
aston_villa = Team.create name: { en: 'Aston Villa', ru: 'Астон Вилла' }, short_name: 'AVL'
newcastle = Team.create name: { en: 'Newcastle United', ru: 'Ньюкасл' }, short_name: 'NEW'
brighton = Team.create name: { en: 'Brighton & Hove Albion', ru: 'Брайтон' }, short_name: 'BHA'
manchester = Team.create name: { en: 'Manchester United', ru: 'Манчестер Югайтед' }, short_name: 'MAN'
west_ham = Team.create name: { en: 'West Ham United', ru: 'Вест Хэм' }, short_name: 'WHU'
brentford = Team.create name: { en: 'Brentford', ru: 'Брентфорд' }, short_name: 'BRE'
chelsea = Team.create name: { en: 'Chelsea', ru: 'Челси' }, short_name: 'CHE'
wolvs = Team.create name: { en: 'Wolverhampton Wanderers', ru: 'Вулверхэмптон' }, short_name: 'WOL'
crystal_palace = Team.create name: { en: 'Crystal Palace', ru: 'Кристал Пэлэс' }, short_name: 'CRY'
fulham = Team.create name: { en: 'Fulham', ru: 'Фулхэм' }, short_name: 'FUL'
everton = Team.create name: { en: 'Everton', ru: 'Эвертон' }, short_name: 'EVE'
nottingham = Team.create name: { en: 'Nottingham Forest', ru: 'Ноттингем' }, short_name: 'NOT'
bournemouth = Team.create name: { en: 'Bournemouth', ru: 'Борнмут' }, short_name: 'BOR'
luton = Team.create name: { en: 'Luton Town', ru: 'Лутон' }, short_name: 'LUT'
burnley = Team.create name: { en: 'Burnley', ru: 'Бёрнли' }, short_name: 'BUR'
sheffield = Team.create name: { en: 'Sheffield United', ru: 'Шеффилд' }, short_name: 'SHE'

team1_fantasy_rpl_league = league2024.all_fantasy_leagues.create leagueable: tottenham, name: 'Tottenham', global: true
team2_fantasy_rpl_league = league2024.all_fantasy_leagues.create leagueable: arsenal, name: 'Arsenal', global: true
team3_fantasy_rpl_league = league2024.all_fantasy_leagues.create leagueable: manchester_city, name: 'Man City', global: true
team4_fantasy_rpl_league = league2024.all_fantasy_leagues.create leagueable: liverpool, name: 'Liverpool', global: true
team5_fantasy_rpl_league = league2024.all_fantasy_leagues.create leagueable: aston_villa, name: 'Aston Villa', global: true
team6_fantasy_rpl_league = league2024.all_fantasy_leagues.create leagueable: newcastle, name: 'Newcastle', global: true
team7_fantasy_rpl_league = league2024.all_fantasy_leagues.create leagueable: brighton, name: 'Brighton', global: true
team8_fantasy_rpl_league = league2024.all_fantasy_leagues.create leagueable: manchester, name: 'Man United', global: true
team9_fantasy_rpl_league = league2024.all_fantasy_leagues.create leagueable: west_ham, name: 'West Ham', global: true
team10_fantasy_rpl_league = league2024.all_fantasy_leagues.create leagueable: brentford, name: 'Brentford', global: true
team11_fantasy_rpl_league = league2024.all_fantasy_leagues.create leagueable: chelsea, name: 'Chelsea', global: true
team12_fantasy_rpl_league = league2024.all_fantasy_leagues.create leagueable: wolvs, name: 'Wolvs', global: true
team13_fantasy_rpl_league = league2024.all_fantasy_leagues.create leagueable: crystal_palace, name: 'Crystal Palace', global: true
team14_fantasy_rpl_league = league2024.all_fantasy_leagues.create leagueable: fulham, name: 'Fulham', global: true
team15_fantasy_rpl_league = league2024.all_fantasy_leagues.create leagueable: everton, name: 'Everton', global: true
team16_fantasy_rpl_league = league2024.all_fantasy_leagues.create leagueable: nottingham, name: 'Nottingham', global: true
team13_fantasy_rpl_league = league2024.all_fantasy_leagues.create leagueable: bournemouth, name: 'Bournemouth', global: true
team14_fantasy_rpl_league = league2024.all_fantasy_leagues.create leagueable: luton, name: 'Luton', global: true
team15_fantasy_rpl_league = league2024.all_fantasy_leagues.create leagueable: burnley, name: 'Burnley', global: true
team16_fantasy_rpl_league = league2024.all_fantasy_leagues.create leagueable: sheffield, name: 'Sheffield', global: true

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

rows = CSV.read(Rails.root.join('db/data/premier_league_players_2024.csv'), col_sep: ',')

positions = {
  'G' => 'football_goalkeeper',
  'DEF' => 'football_defender',
  'MID' => 'football_midfielder',
  'FOR' => 'football_forward'
}.freeze

rows.each do |row|
  player = Player.create position_kind: positions[row[6]], name: { en: "#{row[2]} #{row[1]}", ru: "#{row[4]} #{row[3]}" }
  players_season = Players::Season.create season: league2024, player: player
  Teams::Player.create seasons_team: eval("#{row[0]}_league2024"), player: player, price_cents: row[7].to_d, shirt_number_string: row[5].to_s, players_season: players_season
end

week12 = league2024.weeks.create position: 12, status: 'coming', deadline_at: DateTime.new(2023, 11, 11, 11, 0, 0)
week13 = league2024.weeks.create position: 13, deadline_at: DateTime.new(2023, 11, 25, 11, 0, 0)

Games::CreateService.call(
  params: {
    week_id: week12.id,
    home_season_team_id: wolvs_league2024.id,
    visitor_season_team_id: tottenham_league2024.id,
    start_at: DateTime.new(2023, 11, 11, 12, 30, 0)
  }
)

Games::CreateService.call(
  params: {
    week_id: week12.id,
    home_season_team_id: arsenal_league2024.id,
    visitor_season_team_id: burnley_league2024.id,
    start_at: DateTime.new(2023, 11, 11, 15, 0, 0)
  }
)

Games::CreateService.call(
  params: {
    week_id: week12.id,
    home_season_team_id: chelsea_league2024.id,
    visitor_season_team_id: manchester_city_league2024.id,
    start_at: DateTime.new(2023, 11, 12, 16, 30, 0)
  }
)

Games::CreateService.call(
  params: {
    week_id: week13.id,
    home_season_team_id: manchester_city_league2024.id,
    visitor_season_team_id: liverpool_league2024.id,
    start_at: DateTime.new(2023, 11, 25, 12, 30, 0)
  }
)


