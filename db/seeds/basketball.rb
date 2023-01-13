require 'csv'

nba = League.create(sport_kind: 'basketball', name: { en: 'NBA', ru: 'НБА' })

nba2023 = nba.seasons.create name: '2022/2023', active: true

overall_fantasy_nba_league = nba2023.all_fantasy_leagues.create leagueable: nba2023, name: 'Overall', global: true

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

milwaukee_nba2023 = Seasons::Team.create team: milwaukee, season: nba2023
miami_nba2023 = Seasons::Team.create team: miami, season: nba2023
philadelphia_nba2023 = Seasons::Team.create team: philadelphia, season: nba2023
chicago_nba2023 = Seasons::Team.create team: chicago, season: nba2023
boston_nba2023 = Seasons::Team.create team: boston, season: nba2023
phoenix_nba2023 = Seasons::Team.create team: phoenix, season: nba2023
golden_state_nba2023 = Seasons::Team.create team: golden_state, season: nba2023
dallas_nba2023 = Seasons::Team.create team: dallas, season: nba2023
lal_nba2023 = Seasons::Team.create team: lal, season: nba2023
denver_nba2023 = Seasons::Team.create team: denver, season: nba2023
cleveland_nba2023 = Seasons::Team.create team: cleveland, season: nba2023
indiana_nba2023 = Seasons::Team.create team: indiana, season: nba2023
atlanta_nba2023 = Seasons::Team.create team: atlanta, season: nba2023
brooklyn_nba2023 = Seasons::Team.create team: brooklyn, season: nba2023
toronto_nba2023 = Seasons::Team.create team: toronto, season: nba2023
knicks_nba2023 = Seasons::Team.create team: knicks, season: nba2023
washington_nba2023 = Seasons::Team.create team: washington, season: nba2023
charlotte_nba2023 = Seasons::Team.create team: charlotte, season: nba2023
detroit_nba2023 = Seasons::Team.create team: detroit, season: nba2023
orlando_nba2023 = Seasons::Team.create team: orlando, season: nba2023
pelicans_nba2023 = Seasons::Team.create team: pelicans, season: nba2023
memphis_nba2023 = Seasons::Team.create team: memphis, season: nba2023
sacramento_nba2023 = Seasons::Team.create team: sacramento, season: nba2023
lac_nba2023 = Seasons::Team.create team: lac, season: nba2023
portland_nba2023 = Seasons::Team.create team: portland, season: nba2023
utah_nba2023 = Seasons::Team.create team: utah, season: nba2023
minnesota_nba2023 = Seasons::Team.create team: minnesota, season: nba2023
oklahoma_nba2023 = Seasons::Team.create team: oklahoma, season: nba2023
houston_nba2023 = Seasons::Team.create team: houston, season: nba2023
spurs_nba2023 = Seasons::Team.create team: spurs, season: nba2023

nba2023.seasons_teams.each do |seasons_teams|
  nba2023.all_fantasy_leagues.create leagueable: seasons_teams.team, name: seasons_teams.team.name['en'], global: true
end

rows = CSV.read(Rails.root.join('db/data/nba_players_2023.csv'), col_sep: ',')

positions = {
  'C' => 'basketball_center',
  'PG' => 'basketball_point_guard',
  'SG' => 'basketball_shooting_guard',
  'PF' => 'basketball_power_forward',
  'SF' => 'basketball_small_forward'
}.freeze

def price(value)
  return 2_500 if value >= 45
  return 2_250 if value >= 40
  return 2_000 if value >= 35
  return 1_750 if value >= 30
  return 1_500 if value >= 25
  return 1_300 if value >= 20
  return 1_100 if value >= 17.5
  return 900 if value >= 15
  return 750 if value >= 12.5
  return 600 if value >= 10
  return 500 if value >= 7.5

  400
end

rows.each do |row|
  player = Player.create position_kind: positions[row[6]], name: { en: "#{row[2]} #{row[1]}", ru: "#{row[4]} #{row[3]}" }

  Teams::Player.create seasons_team: eval("#{row[0]}_nba2023"), player: player, price_cents: (row[7] == 'TW' ? 400 : price(row[7].to_d)), shirt_number: row[5].to_i
end

week1 = nba2023.weeks.create position: 1, status: 'coming', deadline_at: DateTime.new(2022, 10, 18, 12, 0, 0)
week2 = nba2023.weeks.create position: 2, deadline_at: DateTime.new(2022, 10, 24, 12, 0, 0)
week3 = nba2023.weeks.create position: 3, deadline_at: DateTime.new(2022, 10, 31, 12, 0, 0)
week4 = nba2023.weeks.create position: 4, deadline_at: DateTime.new(2022, 11, 7, 12, 0, 0)
week5 = nba2023.weeks.create position: 5, deadline_at: DateTime.new(2022, 11, 14, 12, 0, 0)
week6 = nba2023.weeks.create position: 6, deadline_at: DateTime.new(2022, 11, 21, 12, 0, 0)
week7 = nba2023.weeks.create position: 7, deadline_at: DateTime.new(2022, 11, 28, 12, 0, 0)
week8 = nba2023.weeks.create position: 8, deadline_at: DateTime.new(2022, 12, 5, 12, 0, 0)
week9 = nba2023.weeks.create position: 9, deadline_at: DateTime.new(2022, 12, 12, 12, 0, 0)
week10 = nba2023.weeks.create position: 10, deadline_at: DateTime.new(2022, 12, 19, 12, 0, 0)
week11 = nba2023.weeks.create position: 11, deadline_at: DateTime.new(2022, 12, 26, 12, 0, 0)
week12 = nba2023.weeks.create position: 12, deadline_at: DateTime.new(2023, 1, 2, 12, 0, 0)
week13 = nba2023.weeks.create position: 13, deadline_at: DateTime.new(2023, 1, 9, 12, 0, 0)
week14 = nba2023.weeks.create position: 14, deadline_at: DateTime.new(2023, 1, 16, 12, 0, 0)
week15 = nba2023.weeks.create position: 15, deadline_at: DateTime.new(2023, 1, 23, 12, 0, 0)
week16 = nba2023.weeks.create position: 16, deadline_at: DateTime.new(2023, 1, 30, 12, 0, 0)
week17 = nba2023.weeks.create position: 17, deadline_at: DateTime.new(2023, 2, 6, 12, 0, 0)
week18 = nba2023.weeks.create position: 18, deadline_at: DateTime.new(2023, 2, 13, 12, 0, 0)
week19 = nba2023.weeks.create position: 19, deadline_at: DateTime.new(2023, 2, 20, 12, 0, 0)
week20 = nba2023.weeks.create position: 20, deadline_at: DateTime.new(2023, 2, 27, 12, 0, 0)
week21 = nba2023.weeks.create position: 21, deadline_at: DateTime.new(2023, 3, 6, 12, 0, 0)
week22 = nba2023.weeks.create position: 22, deadline_at: DateTime.new(2023, 3, 13, 12, 0, 0)
week23 = nba2023.weeks.create position: 23, deadline_at: DateTime.new(2023, 3, 20, 12, 0, 0)
week24 = nba2023.weeks.create position: 24, deadline_at: DateTime.new(2023, 3, 27, 12, 0, 0)
week25 = nba2023.weeks.create position: 25, deadline_at: DateTime.new(2023, 4, 3, 12, 0, 0)

nba2023.teams.each.with_index do |team, team_index|
  team_fantasy_league = team.fantasy_leagues.last
  20.times do |index|
    user = Users::CreateService.call(params: { email: "basketball-team-#{team_index}-#{index}@gmail.com", password: '1234qwerQWER', password_confirmation: '1234qwerQWER' }, with_send_confirmation: false).result
    FantasyTeams::GenerateSampleService.call(season: nba2023, user: user, favourite_team_uuid: team.uuid)
  end
end

games_rows = CSV.read(Rails.root.join('db/data/nba_games_2023.csv'), col_sep: ',')
active_week = week1
next_week = week2
seasons_teams = nba2023.seasons_teams.map { |e| [e.team.short_name, e.id] }.to_h

games_rows.each do |row|
  game_time = DateTime.parse(row[1])
  if next_week && game_time > next_week.deadline_at
    active_week = next_week
    next_week = next_week.season.weeks.find_by(position: next_week.position + 1)
  end

  Games::CreateService.call(
    week_id:                active_week.id,
    home_season_team_id:    seasons_teams[row[2]],
    visitor_season_team_id: seasons_teams[row[3]],
    source:                 Sourceable::SPORTRADAR,
    external_id:            row[0],
    start_at:               game_time
  )
end
