require 'csv'

nba = League.create(sport_kind: 'basketball', name: { en: 'NBA', ru: 'НБА' }, points_system: { W: 1, L: 0 })

nba2024 = nba.seasons.create(
  name: '2023/2024',
  active: true,
  start_at: DateTime.new(2023, 10, 16, 0, 0, 0),
  members_count: 30,
  Sourceable::SPORTS
)

overall_fantasy_nba_league = nba2024.all_fantasy_leagues.create leagueable: nba2024, name: 'Overall', global: true

milwaukee = Team.create name: { en: 'Milwaukee Bucks', ru: 'Милуоки Бакс' }, short_name: 'MIL'
miami = Team.create name: { en: 'Miami Heat', ru: 'Майами Хит' }, short_name: 'MIA'
philadelphia = Team.create name: { en: 'Philadelphia 76ers', ru: 'Филадельфия Сиксерс' }, short_name: 'PHI'
chicago = Team.create name: { en: 'Chicago Bulls', ru: 'Чикаго Буллз' }, short_name: 'CHI'
boston = Team.create name: { en: 'Boston Celtics', ru: 'Бостон Селтикс' }, short_name: 'BOS'
cleveland = Team.create name: { en: 'Cleveland Cavaliers', ru: 'Кливленд Кавальерс' }, short_name: 'CLE'
indiana = Team.create name: { en: 'Indiana Pacers', ru: 'Индиана Пейсерс' }, short_name: 'IND'
atlanta = Team.create name: { en: 'Atlanta Hawks', ru: 'Атланта Хоукс' }, short_name: 'ATL'
brooklyn = Team.create name: { en: 'Brooklyn Nets', ru: 'Бруклин Нетс' }, short_name: 'BKN'
toronto = Team.create name: { en: 'Toronto Raptors', ru: 'Торонто Рэпторз' }, short_name: 'TOR'
knicks = Team.create name: { en: 'New York Knicks', ru: 'Нью-Йорк Никс' }, short_name: 'NYK'
washington = Team.create name: { en: 'Washington Wizards', ru: 'Вашингтон Уизардс' }, short_name: 'WAS'
charlotte = Team.create name: { en: 'Charlotte Hornets', ru: 'Шарлотт Хорнетс' }, short_name: 'CHA'
detroit = Team.create name: { en: 'Detroit Pistons', ru: 'Детройт Пистонс' }, short_name: 'DET'
orlando = Team.create name: { en: 'Orlando Magic', ru: 'Орландо Мэджик' }, short_name: 'ORL'
phoenix = Team.create name: { en: 'Phoenix Suns', ru: 'Финикс Санз' }, short_name: 'PHX'
golden_state = Team.create name: { en: 'Golden State Warriors', ru: 'Голден Стэйт Уорриорз' }, short_name: 'GSW'
dallas = Team.create name: { en: 'Dallas Mavericks', ru: 'Даллас Маверикс' }, short_name: 'DAL'
lal = Team.create name: { en: 'Los Angeles Lakers', ru: 'Лос-Анджелес Лейкерс' }, short_name: 'LAL'
denver = Team.create name: { en: 'Denver Nuggets', ru: 'Денвер Наггетс' }, short_name: 'DEN'
pelicans = Team.create name: { en: 'New Orlean Pelicans', ru: 'Нью-Орлеан Пеликанс' }, short_name: 'NOP'
memphis = Team.create name: { en: 'Memphis Grizzlies', ru: 'Мемфис Гриззлиз' }, short_name: 'MEM'
sacramento = Team.create name: { en: 'Sacramento Kings', ru: 'Сакраменто Кингз' }, short_name: 'SAC'
lac = Team.create name: { en: 'Los Angeles Clippers', ru: 'Лос-Анджелес Клипперс' }, short_name: 'LAC'
portland = Team.create name: { en: 'Portland Trail Blazers', ru: 'Портленд Трэйл Блэйзерс' }, short_name: 'POR'
utah = Team.create name: { en: 'Utah Jazz', ru: 'Юта Джаз' }, short_name: 'UTA'
minnesota = Team.create name: { en: 'Minnesota Timberwolves', ru: 'Миннесота Тимбервулвз' }, short_name: 'MIN'
oklahoma = Team.create name: { en: 'Oklahoma City Thunder', ru: 'Оклахома-Сити Тандер' }, short_name: 'OKC'
houston = Team.create name: { en: 'Houston Rockets', ru: 'Хьюстон Рокетс' }, short_name: 'HOU'
spurs = Team.create name: { en: 'San Antonio Spurs', ru: 'Сан-Антонио Спёрс' }, short_name: 'SAS'

milwaukee_nba2024 = Seasons::Team.create team: milwaukee, season: nba2024
miami_nba2024 = Seasons::Team.create team: miami, season: nba2024
philadelphia_nba2024 = Seasons::Team.create team: philadelphia, season: nba2024
chicago_nba2024 = Seasons::Team.create team: chicago, season: nba2024
boston_nba2024 = Seasons::Team.create team: boston, season: nba2024
phoenix_nba2024 = Seasons::Team.create team: phoenix, season: nba2024
golden_state_nba2024 = Seasons::Team.create team: golden_state, season: nba2024
dallas_nba2024 = Seasons::Team.create team: dallas, season: nba2024
lal_nba2024 = Seasons::Team.create team: lal, season: nba2024
denver_nba2024 = Seasons::Team.create team: denver, season: nba2024
cleveland_nba2024 = Seasons::Team.create team: cleveland, season: nba2024
indiana_nba2024 = Seasons::Team.create team: indiana, season: nba2024
atlanta_nba2024 = Seasons::Team.create team: atlanta, season: nba2024
brooklyn_nba2024 = Seasons::Team.create team: brooklyn, season: nba2024
toronto_nba2024 = Seasons::Team.create team: toronto, season: nba2024
knicks_nba2024 = Seasons::Team.create team: knicks, season: nba2024
washington_nba2024 = Seasons::Team.create team: washington, season: nba2024
charlotte_nba2024 = Seasons::Team.create team: charlotte, season: nba2024
detroit_nba2024 = Seasons::Team.create team: detroit, season: nba2024
orlando_nba2024 = Seasons::Team.create team: orlando, season: nba2024
pelicans_nba2024 = Seasons::Team.create team: pelicans, season: nba2024
memphis_nba2024 = Seasons::Team.create team: memphis, season: nba2024
sacramento_nba2024 = Seasons::Team.create team: sacramento, season: nba2024
lac_nba2024 = Seasons::Team.create team: lac, season: nba2024
portland_nba2024 = Seasons::Team.create team: portland, season: nba2024
utah_nba2024 = Seasons::Team.create team: utah, season: nba2024
minnesota_nba2024 = Seasons::Team.create team: minnesota, season: nba2024
oklahoma_nba2024 = Seasons::Team.create team: oklahoma, season: nba2024
houston_nba2024 = Seasons::Team.create team: houston, season: nba2024
spurs_nba2024 = Seasons::Team.create team: spurs, season: nba2024

nba2024.seasons_teams.each do |seasons_teams|
  nba2024.all_fantasy_leagues.create leagueable: seasons_teams.team, name: seasons_teams.team.name['en'], global: true
end

rows = CSV.read(Rails.root.join('db/data/nba_players_2024.csv'), col_sep: ',')

positions = {
  'C' => 'basketball_center',
  'PG' => 'basketball_point_guard',
  'SG' => 'basketball_shooting_guard',
  'PF' => 'basketball_power_forward',
  'SF' => 'basketball_small_forward'
}.freeze

def price(value)
  return 2_250 if value >= 45 # 2000
  return 2_000 if value >= 40 # 1850
  return 1_800 if value >= 35 # 1700
  return 1_600 if value >= 30 # 1500
  return 1_400 if value >= 25 # 1350
  return 1_200 if value >= 20 # 1150
  return 1_000 if value >= 17.5 # 1000
  return 900 if value >= 15
  return 750 if value >= 12.5
  return 600 if value >= 10
  return 500 if value >= 7.5

  400
end

rows.each do |row|
  player = Player.create(
    position_kind: positions[row[6]],
    first_name: { en: row[1], ru: row[3] },
    last_name: { en: row[2], ru: row[4] },
    name: { en: "#{row[2]} #{row[1]}", ru: "#{row[4]} #{row[3]}" }
  )
  players_season = Players::Season.create season: nba2024, player: player
  Teams::Player.create(
    seasons_team: eval("#{row[0]}_nba2024"),
    player: player,
    price_cents: (row[7] == 'TW' ? 400 : price(row[7].to_d)),
    shirt_number_string: row[5].to_s,
    players_season: players_season
  )
end

week1 = nba2024.weeks.create position: 1, status: 'coming', deadline_at: DateTime.new(2023, 10, 24, 20, 0, 0)
week2 = nba2024.weeks.create position: 2, deadline_at: DateTime.new(2023, 10, 30, 20, 0, 0)
week3 = nba2024.weeks.create position: 3, deadline_at: DateTime.new(2023, 11, 6, 20, 0, 0)
week4 = nba2024.weeks.create position: 4, deadline_at: DateTime.new(2023, 11, 13, 20, 0, 0)
week5 = nba2024.weeks.create position: 5, deadline_at: DateTime.new(2023, 11, 20, 20, 0, 0)
week6 = nba2024.weeks.create position: 6, deadline_at: DateTime.new(2023, 11, 27, 20, 0, 0)
week7 = nba2024.weeks.create position: 7, deadline_at: DateTime.new(2023, 12, 4, 20, 0, 0)
week8 = nba2024.weeks.create position: 8, deadline_at: DateTime.new(2023, 12, 11, 20, 0, 0)
week9 = nba2024.weeks.create position: 9, deadline_at: DateTime.new(2023, 12, 18, 20, 0, 0)
week10 = nba2024.weeks.create position: 10, deadline_at: DateTime.new(2023, 12, 25, 20, 0, 0)
week11 = nba2024.weeks.create position: 11, deadline_at: DateTime.new(2024, 1, 1, 20, 0, 0)
week12 = nba2024.weeks.create position: 12, deadline_at: DateTime.new(2024, 1, 8, 20, 0, 0)
week13 = nba2024.weeks.create position: 13, deadline_at: DateTime.new(2024, 1, 15, 20, 0, 0)
week14 = nba2024.weeks.create position: 14, deadline_at: DateTime.new(2024, 1, 22, 20, 0, 0)
week15 = nba2024.weeks.create position: 15, deadline_at: DateTime.new(2024, 1, 29, 20, 0, 0)
week16 = nba2024.weeks.create position: 16, deadline_at: DateTime.new(2024, 2, 5, 20, 0, 0)
week17 = nba2024.weeks.create position: 17, deadline_at: DateTime.new(2024, 2, 12, 20, 0, 0)
week18 = nba2024.weeks.create position: 18, deadline_at: DateTime.new(2024, 2, 19, 20, 0, 0)
week19 = nba2024.weeks.create position: 19, deadline_at: DateTime.new(2024, 2, 26, 20, 0, 0)
week20 = nba2024.weeks.create position: 20, deadline_at: DateTime.new(2024, 3, 4, 20, 0, 0)
week21 = nba2024.weeks.create position: 21, deadline_at: DateTime.new(2024, 3, 11, 20, 0, 0)
week22 = nba2024.weeks.create position: 22, deadline_at: DateTime.new(2024, 3, 18, 20, 0, 0)
week23 = nba2024.weeks.create position: 23, deadline_at: DateTime.new(2024, 3, 25, 20, 0, 0)
week24 = nba2024.weeks.create position: 24, deadline_at: DateTime.new(2024, 4, 1, 20, 0, 0)
week25 = nba2024.weeks.create position: 25, deadline_at: DateTime.new(2024, 4, 8, 20, 0, 0)

# nba2024.teams.each.with_index do |team, team_index|
#   team_fantasy_league = team.fantasy_leagues.last
#   20.times do |index|
#     user = FantasySports::Container['forms.users.create'].call(params: { email: "basketball-team-#{team_index}-#{index}@gmail.com", password: '1234qwerQWER', password_confirmation: '1234qwerQWER' }, with_send_confirmation: false).result
#     FantasyTeams::GenerateSampleService.call(season: nba2024, user: user, favourite_team_uuid: team.uuid)
#   end
# end

games_rows = CSV.read(Rails.root.join('db/data/nba_games_2024.csv'), col_sep: ',')
active_week = week1
next_week = week2
seasons_teams = nba2024.seasons_teams.map { |e| [e.team.short_name, e.id] }.to_h

games_rows.each do |row|
  game_time = DateTime.parse(row[1])

  if next_week && game_time > next_week.deadline_at
    active_week = next_week
    next_week = next_week.season.weeks.find_by(position: next_week.position + 1)
  end

  result = FantasySports::Container['forms.games.create'].call(
    params: {
      week_id: active_week.id,
      home_season_team_id: seasons_teams[row[2]],
      visitor_season_team_id: seasons_teams[row[3]],
      start_at: game_time
    }
  )

  Games::ExternalSource.create(game_id: result[:result], source: Sourceable::SPORTRADAR, external_id: row[0])
end

games_rows = CSV.read(Rails.root.join('db/data/nba_games_sports_2024.csv'), col_sep: ',')
games_rows.each do |row|
  game_time = DateTime.parse(row[1])
  game = Game.find_by(
    start_at: game_time,
    home_season_team_id: seasons_teams[row[2]],
    visitor_season_team_id: seasons_teams[row[3]]
  )
  next if game.nil?

  Games::ExternalSource.create(game_id: game.id, source: Sourceable::SPORTS, external_id: row[0])
end

# missed games
# ["12931", "2023-12-23T00:30:00.000Z", "BKN", "DEN"]
# ["13470", "2024-03-10T02:00:00.000Z", "DEN", "UTA"]

# for adding new games of in-season tournament
# active_week = nba2024.weeks.find_by(position: 7)
# games_rows.each do |row|
#   next if Game.find_by(external_id: row[0])

#   FantasySports::Container['forms.games.create'].call(
#     params: {
#       week_id: active_week.id,
#       home_season_team_id: seasons_teams[row[2]],
#       visitor_season_team_id: seasons_teams[row[3]],
#       source: Sourceable::SPORTRADAR,
#       external_id: row[0],
#       start_at: DateTime.parse(row[1])
#     }
#   )
# end
