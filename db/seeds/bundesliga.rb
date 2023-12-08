require 'csv'

league = League.create(
  sport_kind: 'football',
  name: { en: 'Bundesliga', ru: 'Бундеслига' },
  points_system: { W: 3, D: 1, L: 0 }
)

league2024 = league.seasons.create(
  name: '2023/2024',
  active: false,
  members_count: 18,
  start_at: DateTime.new(2023, 12, 13, 0, 0, 0),
)

overall_league = league2024.all_fantasy_leagues.create leagueable: league2024, name: 'Overall', global: true

eintracht = Team.create name: { en: 'Eintracht', ru: 'Айнтрахт' }, short_name: 'EIN'
augsburg = Team.create name: { en: 'Augsburg', ru: 'Аугсбург' }, short_name: 'AUG'
bayern = Team.create name: { en: 'Bayern', ru: 'Бавария' }, short_name: 'BRN'
bayer = Team.create name: { en: 'Bayer', ru: 'Байер' }, short_name: 'BAY'
borussia_d = Team.create name: { en: 'Borussia D', ru: 'Боруссия Д' }, short_name: 'BRD'
borussia_m = Team.create name: { en: 'Borussia M', ru: 'Боруссия М' }, short_name: 'BRM'
bochum = Team.create name: { en: 'Bochum', ru: 'Бохум' }, short_name: 'BCH'
werder = Team.create name: { en: 'Werder', ru: 'Вердер' }, short_name: 'WER'
wolfsburg = Team.create name: { en: 'Wolfsburg', ru: 'Вольфсбург' }, short_name: 'WLF'
darmstadt = Team.create name: { en: 'Darmstadt 98', ru: 'Дармштадт 98' }, short_name: 'DRM'
koln = Team.create name: { en: 'Koln', ru: 'Кёльн' }, short_name: 'KLN'
mainz = Team.create name: { en: 'Mainz', ru: 'Майнц' }, short_name: 'MAI'
leipzig = Team.create name: { en: 'Leipzig', ru: 'РБ Лейпциг' }, short_name: 'LPZ'
union = Team.create name: { en: 'Union', ru: 'Унион' }, short_name: 'UNI'
freiburg = Team.create name: { en: 'Freiburg', ru: 'Фрайбург' }, short_name: 'FRE'
heidenheim = Team.create name: { en: 'Heidenheim', ru: 'Хайденхайм' }, short_name: 'HEI'
hoffenheim = Team.create name: { en: 'Hoffenheim', ru: 'Хоффенхайм' }, short_name: 'HOF'
stuttgart = Team.create name: { en: 'Stuttgart', ru: 'Штутгарт' }, short_name: 'STG'

league2024.all_fantasy_leagues.create leagueable: eintracht, name: 'Eintracht', global: true
league2024.all_fantasy_leagues.create leagueable: augsburg, name: 'Augsburg', global: true
league2024.all_fantasy_leagues.create leagueable: bayern, name: 'Bayern', global: true
league2024.all_fantasy_leagues.create leagueable: bayer, name: 'Bayer', global: true
league2024.all_fantasy_leagues.create leagueable: borussia_d, name: 'Borussia D', global: true
league2024.all_fantasy_leagues.create leagueable: borussia_m, name: 'Borussia M', global: true
league2024.all_fantasy_leagues.create leagueable: bochum, name: 'Bochum', global: true
league2024.all_fantasy_leagues.create leagueable: werder, name: 'Werder', global: true
league2024.all_fantasy_leagues.create leagueable: wolfsburg, name: 'Wolfsburg', global: true
league2024.all_fantasy_leagues.create leagueable: darmstadt, name: 'Darmstadt 98', global: true
league2024.all_fantasy_leagues.create leagueable: koln, name: 'Koln', global: true
league2024.all_fantasy_leagues.create leagueable: mainz, name: 'Mainz', global: true
league2024.all_fantasy_leagues.create leagueable: leipzig, name: 'Leipzig', global: true
league2024.all_fantasy_leagues.create leagueable: union, name: 'Union', global: true
league2024.all_fantasy_leagues.create leagueable: freiburg, name: 'Freiburg', global: true
league2024.all_fantasy_leagues.create leagueable: heidenheim, name: 'Heidenheim', global: true
league2024.all_fantasy_leagues.create leagueable: hoffenheim, name: 'Hoffenheim', global: true
league2024.all_fantasy_leagues.create leagueable: stuttgart, name: 'Stuttgart', global: true

eintracht_league2024 = Seasons::Team.create team: eintracht, season: league2024
augsburg_league2024 = Seasons::Team.create team: augsburg, season: league2024
bayern_league2024 = Seasons::Team.create team: bayern, season: league2024
bayer_league2024 = Seasons::Team.create team: bayer, season: league2024
borussia_d_league2024 = Seasons::Team.create team: borussia_d, season: league2024
borussia_m_league2024 = Seasons::Team.create team: borussia_m, season: league2024
bochum_league2024 = Seasons::Team.create team: bochum, season: league2024
werder_league2024 = Seasons::Team.create team: werder, season: league2024
wolfsburg_league2024 = Seasons::Team.create team: wolfsburg, season: league2024
darmstadt_league2024 = Seasons::Team.create team: darmstadt, season: league2024
koln_league2024 = Seasons::Team.create team: koln, season: league2024
mainz_league2024 = Seasons::Team.create team: mainz, season: league2024
leipzig_league2024 = Seasons::Team.create team: leipzig, season: league2024
union_league2024 = Seasons::Team.create team: union, season: league2024
freiburg_league2024 = Seasons::Team.create team: freiburg, season: league2024
heidenheim_league2024 = Seasons::Team.create team: heidenheim, season: league2024
hoffenheim_league2024 = Seasons::Team.create team: hoffenheim, season: league2024
stuttgart_league2024 = Seasons::Team.create team: stuttgart, season: league2024

rows = CSV.read(Rails.root.join('db/data/bundesliga_players_2024.csv'), col_sep: ';')

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

games_rows = CSV.read(Rails.root.join('db/data/bundesliga_games_2024.csv'), col_sep: ',')
seasons_teams = league2024.seasons_teams.map { |e| [e.team.short_name, e.id] }.to_h
weeks_positions = league2024.weeks.map { |e| [e.position, e.id] }.to_h

games_rows.each do |row|
  FantasySports::Container['forms.games.create'].call(
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
