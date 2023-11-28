require 'csv'

league = League.create(
  sport_kind: 'football',
  name: { en: 'La Liga', ru: 'Примера' },
  points_system: { W: 3, D: 1, L: 0 }
)

league2024 = league.seasons.create(
  name: '2023/2024',
  active: false,
  members_count: 20,
  start_at: DateTime.new(2023, 12, 4, 0, 0, 0),
)

overall_league = league2024.all_fantasy_leagues.create leagueable: league2024, name: 'Overall', global: true

alaves = Team.create name: { en: 'Alaves', ru: 'Алавес' }, short_name: 'ALA'
almeria = Team.create name: { en: 'Almeria', ru: 'Альмерия' }, short_name: 'ALM'
athletic = Team.create name: { en: 'Athletic', ru: 'Атлетик' }, short_name: 'ATH'
atletico = Team.create name: { en: 'Atletico', ru: 'Атлетико' }, short_name: 'ATL'
barcelona = Team.create name: { en: 'Barcelona', ru: 'Барселона' }, short_name: 'BAR'
betis = Team.create name: { en: 'Betis', ru: 'Бетис' }, short_name: 'BET'
valencia = Team.create name: { en: 'Valencia', ru: 'Валенсия' }, short_name: 'VAL'
villarreal = Team.create name: { en: 'Villareal', ru: 'Вильярреал' }, short_name: 'VIL'
granada = Team.create name: { en: 'Granada', ru: 'Гранада' }, short_name: 'GRA'
girona = Team.create name: { en: 'Girona', ru: 'Жирона' }, short_name: 'GIR'
cadiz = Team.create name: { en: 'Cadiz', ru: 'Кадис' }, short_name: 'CAD'
laspalmas = Team.create name: { en: 'Las Palmas', ru: 'Лас-Пальмас' }, short_name: 'LAS'
mallorca = Team.create name: { en: 'Mallorca', ru: 'Майорка' }, short_name: 'MAL'
osasuna = Team.create name: { en: 'Osasuna', ru: 'Осасуна' }, short_name: 'OSA'
rayovallecano = Team.create name: { en: 'Rayo Vallecano', ru: 'Райо Вальекано' }, short_name: 'RAY'
real_madrid = Team.create name: { en: 'Real Madrid', ru: 'Реал Мадрид' }, short_name: 'RLM'
real_sociedad = Team.create name: { en: 'Real Sociedad', ru: 'Реаль Сосьедад' }, short_name: 'RLS'
celta = Team.create name: { en: 'Celta', ru: 'Сельта' }, short_name: 'CEL'
getafe = Team.create name: { en: 'Getafe', ru: 'Хетафе' }, short_name: 'GET'
sevilla = Team.create name: { en: 'Sevilla', ru: 'Севилья' }, short_name: 'SEV'

league2024.all_fantasy_leagues.create leagueable: alaves, name: 'Alaves', global: true
league2024.all_fantasy_leagues.create leagueable: almeria, name: 'Almeria', global: true
league2024.all_fantasy_leagues.create leagueable: athletic, name: 'Athletic', global: true
league2024.all_fantasy_leagues.create leagueable: atletico, name: 'Atletico', global: true
league2024.all_fantasy_leagues.create leagueable: barcelona, name: 'Barcelona', global: true
league2024.all_fantasy_leagues.create leagueable: betis, name: 'Betis', global: true
league2024.all_fantasy_leagues.create leagueable: valencia, name: 'Valencia', global: true
league2024.all_fantasy_leagues.create leagueable: villarreal, name: 'Villareal', global: true
league2024.all_fantasy_leagues.create leagueable: granada, name: 'Granada', global: true
league2024.all_fantasy_leagues.create leagueable: girona, name: 'Girona', global: true
league2024.all_fantasy_leagues.create leagueable: cadiz, name: 'Cadiz', global: true
league2024.all_fantasy_leagues.create leagueable: laspalmas, name: 'Las Palmas', global: true
league2024.all_fantasy_leagues.create leagueable: mallorca, name: 'Mallorca', global: true
league2024.all_fantasy_leagues.create leagueable: osasuna, name: 'Osasuna', global: true
league2024.all_fantasy_leagues.create leagueable: rayovallecano, name: 'Rayo Vallecano', global: true
league2024.all_fantasy_leagues.create leagueable: real_madrid, name: 'Real Madrid', global: true
league2024.all_fantasy_leagues.create leagueable: real_sociedad, name: 'Real Sociedad', global: true
league2024.all_fantasy_leagues.create leagueable: celta, name: 'Celta', global: true
league2024.all_fantasy_leagues.create leagueable: getafe, name: 'Getafe', global: true
league2024.all_fantasy_leagues.create leagueable: sevilla, name: 'Sevilla', global: true

alaves_league2024 = Seasons::Team.create team: alaves, season: league2024
almeria_league2024 = Seasons::Team.create team: almeria, season: league2024
athletic_league2024 = Seasons::Team.create team: athletic, season: league2024
atletico_league2024 = Seasons::Team.create team: atletico, season: league2024
barcelona_league2024 = Seasons::Team.create team: barcelona, season: league2024
betis_league2024 = Seasons::Team.create team: betis, season: league2024
valencia_league2024 = Seasons::Team.create team: valencia, season: league2024
villarreal_league2024 = Seasons::Team.create team: villarreal, season: league2024
granada_league2024 = Seasons::Team.create team: granada, season: league2024
girona_league2024 = Seasons::Team.create team: girona, season: league2024
cadiz_league2024 = Seasons::Team.create team: cadiz, season: league2024
laspalmas_league2024 = Seasons::Team.create team: laspalmas, season: league2024
mallorca_league2024 = Seasons::Team.create team: mallorca, season: league2024
osasuna_league2024 = Seasons::Team.create team: osasuna, season: league2024
rayovallecano_league2024 = Seasons::Team.create team: rayovallecano, season: league2024
real_madrid_league2024 = Seasons::Team.create team: real_madrid, season: league2024
real_sociedad_league2024 = Seasons::Team.create team: real_sociedad, season: league2024
celta_league2024 = Seasons::Team.create team: celta, season: league2024
getafe_league2024 = Seasons::Team.create team: getafe, season: league2024
sevilla_league2024 = Seasons::Team.create team: sevilla, season: league2024

rows = CSV.read(Rails.root.join('db/data/la_liga_players_2024.csv'), col_sep: ';')

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

games_rows = CSV.read(Rails.root.join('db/data/la_liga_games_2024.csv'), col_sep: ',')
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
