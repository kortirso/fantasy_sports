nba = League.create(sport_kind: 'basketball', name: { en: 'NBA', ru: 'НБА' })

nba2022 = nba.seasons.create name: '2021/2022', active: true

overall_fantasy_nba_league = nba2022.all_fantasy_leagues.create leagueable: nba2022, name: 'Overall', global: true

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

milwaukee_nba2022 = Seasons::Team.create team: milwaukee, season: nba2022
miami_nba2022 = Seasons::Team.create team: miami, season: nba2022
philadelphia_nba2022 = Seasons::Team.create team: philadelphia, season: nba2022
chicago_nba2022 = Seasons::Team.create team: chicago, season: nba2022
boston_nba2022 = Seasons::Team.create team: boston, season: nba2022
phoenix_nba2022 = Seasons::Team.create team: phoenix, season: nba2022
golden_state_nba2022 = Seasons::Team.create team: golden_state, season: nba2022
dallas_nba2022 = Seasons::Team.create team: dallas, season: nba2022
lal_nba2022 = Seasons::Team.create team: lal, season: nba2022
denver_nba2022 = Seasons::Team.create team: denver, season: nba2022
cleveland_nba2022 = Seasons::Team.create team: cleveland, season: nba2022
indiana_nba2022 = Seasons::Team.create team: indiana, season: nba2022
atlanta_nba2022 = Seasons::Team.create team: atlanta, season: nba2022
brooklyn_nba2022 = Seasons::Team.create team: brooklyn, season: nba2022
toronto_nba2022 = Seasons::Team.create team: toronto, season: nba2022
knicks_nba2022 = Seasons::Team.create team: knicks, season: nba2022
washington_nba2022 = Seasons::Team.create team: washington, season: nba2022
charlotte_nba2022 = Seasons::Team.create team: charlotte, season: nba2022
detroit_nba2022 = Seasons::Team.create team: detroit, season: nba2022
orlando_nba2022 = Seasons::Team.create team: orlando, season: nba2022
pelicans_nba2022 = Seasons::Team.create team: pelicans, season: nba2022
memphis_nba2022 = Seasons::Team.create team: memphis, season: nba2022
sacramento_nba2022 = Seasons::Team.create team: sacramento, season: nba2022
lac_nba2022 = Seasons::Team.create team: lac, season: nba2022
portland_nba2022 = Seasons::Team.create team: portland, season: nba2022
utah_nba2022 = Seasons::Team.create team: utah, season: nba2022
minnesota_nba2022 = Seasons::Team.create team: minnesota, season: nba2022
oklahoma_nba2022 = Seasons::Team.create team: oklahoma, season: nba2022
houston_nba2022 = Seasons::Team.create team: houston, season: nba2022
spurs_nba2022 = Seasons::Team.create team: spurs, season: nba2022

nba2022.seasons_teams.each do |seasons_teams|
  nba2022.all_fantasy_leagues.create leagueable: seasons_teams.team, name: seasons_teams.team.name['en'], global: true
end

brooklyn13 = Player.create position_kind: 'basketball_shooting_guard', name: { en: 'Harden James', ru: 'Харден Джеймс' }
brooklyn7 = Player.create position_kind: 'basketball_small_forward', name: { en: 'Durant Kevin', ru: 'Дюрант Кевин' }
brooklyn11 = Player.create position_kind: 'basketball_shooting_guard', name: { en: 'Irving Kyrie', ru: 'Ирвинг Кайри' }
charlotte2 = Player.create position_kind: 'basketball_point_guard', name: { en: 'Ball LsMelo', ru: 'Болл Ламело' }
charlotte20 = Player.create position_kind: 'basketball_small_forward', name: { en: 'Hayward Gordon', ru: 'Хэйворд Гордон' }
indiana10 = Player.create position_kind: 'basketball_center', name: { en: 'Sabonis Domantas', ru: 'Сабонис Домантас' }
indiana7 = Player.create position_kind: 'basketball_point_guard', name: { en: 'Brogdon Malcolm', ru: 'Брогдон Малкольм' }
toronto9 = Player.create position_kind: 'basketball_point_guard', name: { en: 'Dragic Goran', ru: 'Драгич Горан' }
washington33 = Player.create position_kind: 'basketball_small_forward', name: { en: 'Kuzma Kyle', ru: 'Кузма Кайл' }
minnesota1 = Player.create position_kind: 'basketball_shooting_guard', name: { en: 'Edwards Anthony', ru: 'Эдвардс Энтони' }
memphis4 = Player.create position_kind: 'basketball_center', name: { en: 'Adams Steven', ru: 'Адамс Стивен' }
memphis12 = Player.create position_kind: 'basketball_point_guard', name: { en: 'Morant Ja', ru: 'Морант Джа' }
cleveland24 = Player.create position_kind: 'basketball_small_forward', name: { en: 'Markkanen Lauri', ru: 'Маркканен Лаури' }
cleveland31 = Player.create position_kind: 'basketball_center', name: { en: 'Allen Jarrett', ru: 'Аллен Джарретт' }
utah27 = Player.create position_kind: 'basketball_center', name: { en: 'Gobert Rudy', ru: 'Гобер Руди' }
utah44 = Player.create position_kind: 'basketball_small_forward', name: { en: 'Bogdanovic Bojan', ru: 'Богданович Боян' }
atlanta11 = Player.create position_kind: 'basketball_point_guard', name: { en: 'Young Trae', ru: 'Янг Трей' }

milwaukee34 = Player.create position_kind: 'basketball_power_forward', name: { en: 'Antetokounmpo Giannis', ru: 'Адетокунбо Яннис' }
milwaukee22 = Player.create position_kind: 'basketball_small_forward', name: { en: 'Middleton Khris', ru: 'Миддлтон Крис' }
milwaukee7 = Player.create position_kind: 'basketball_shooting_guard', name: { en: 'Allen Grayson', ru: 'Аллен Грейсон' }

miami22 = Player.create position_kind: 'basketball_small_forward', name: { en: 'Butler Jimmy', ru: 'Батлер Джимми' }
miami55 = Player.create position_kind: 'basketball_shooting_guard', name: { en: 'Robinson Duncan', ru: 'Робинсон Дункан' }
miami17 = Player.create position_kind: 'basketball_power_forward', name: { en: 'Tucker P. J.', ru: 'Такер Пи Джей' }

philadelphia21 = Player.create position_kind: 'basketball_center', name: { en: 'Embiid Joel', ru: 'Эмбиид Джоэл' }
philadelphia20 = Player.create position_kind: 'basketball_power_forward', name: { en: 'Niang Georges', ru: 'Ньянг Жорж' }
philadelphia30 = Player.create position_kind: 'basketball_shooting_guard', name: { en: 'Korkmaz Furkan', ru: 'Коркмаз Фуркан' }

chicago9 = Player.create position_kind: 'basketball_center', name: { en: 'Vucevic Nikola', ru: 'Вучевич Никола' }
chicago2 = Player.create position_kind: 'basketball_point_guard', name: { en: 'Ball Lonzo', ru: 'Болл Лонзо' }
chicago11 = Player.create position_kind: 'basketball_small_forward', name: { en: 'DeRozan DeMar', ru: 'Дерозан Демар' }

boston0 = Player.create position_kind: 'basketball_small_forward', name: { en: 'Tatum Jayson', ru: 'Тейтум Джейсон' }
boston42 = Player.create position_kind: 'basketball_center', name: { en: 'Horford Al', ru: 'Хорфорд Эл' }
boston36 = Player.create position_kind: 'basketball_point_guard', name: { en: 'Smart Marcus', ru: 'Смарт Маркус' }

phoenix3 = Player.create position_kind: 'basketball_point_guard', name: { en: 'Paul Chris', ru: 'Пол Крис' }
phoenix25 = Player.create position_kind: 'basketball_small_forward', name: { en: 'Bridges Mikal', ru: 'Бриджес Микал' }
phoenix99 = Player.create position_kind: 'basketball_power_forward', name: { en: 'Crowder Jae', ru: 'Краудер Джей' }

golden_state30 = Player.create position_kind: 'basketball_point_guard', name: { en: 'Curry Stephen', ru: 'Карри Стефен' }
golden_state22 = Player.create position_kind: 'basketball_power_forward', name: { en: 'Wiggins Andrew', ru: 'Уиггинс Эндрю' }
golden_state32 = Player.create position_kind: 'basketball_small_forward', name: { en: 'Porter Jr. Otto', ru: 'Портер Отто' }

dallas77 = Player.create position_kind: 'basketball_shooting_guard', name: { en: 'Doncic Luka', ru: 'Дончич Лука' }
dallas13 = Player.create position_kind: 'basketball_shooting_guard', name: { en: 'Brunson Jalen', ru: 'Брансон Джейлен' }
dallas25 = Player.create position_kind: 'basketball_small_forward', name: { en: 'Bullock Reggie', ru: 'Баллок Реджи' }

lal6 = Player.create position_kind: 'basketball_small_forward', name: { en: 'James LeBron', ru: 'Джеймс Леброн' }
lal3 = Player.create position_kind: 'basketball_power_forward', name: { en: 'Davis Anthony', ru: 'Дэвис Энтони' }
lal0 = Player.create position_kind: 'basketball_point_guard', name: { en: 'Westbrook Russell', ru: 'Уэстбрук Расселл' }

denver15 = Player.create position_kind: 'basketball_center', name: { en: 'Jokic Nikola', ru: 'Йокич Никола' }
denver50 = Player.create position_kind: 'basketball_power_forward', name: { en: 'Gordon Aaron', ru: 'Гордон Аарон' }
denver11 = Player.create position_kind: 'basketball_point_guard', name: { en: 'Morris Monté', ru: 'Моррис Монте' }

# 45_000_000 => 2_000
# 40_000_000 => 1_750
# 35_000_000 => 1_500
# 30_000_000 => 1_250
# 25_000_000 => 1_100
# 20_000_000 => 1_000
# 15_000_000 => 800
# 10_000_000 => 700
# 7_500_000  => 600
# 5_000_000  => 500

Teams::Player.create seasons_team: milwaukee_nba2022, player: milwaukee34, price_cents: 1_750, shirt_number: 34
Teams::Player.create seasons_team: milwaukee_nba2022, player: milwaukee22, price_cents: 1_500, shirt_number: 22
Teams::Player.create seasons_team: milwaukee_nba2022, player: milwaukee7, price_cents: 500, shirt_number: 7
Teams::Player.create seasons_team: miami_nba2022, player: miami22, price_cents: 1_500, shirt_number: 22
Teams::Player.create seasons_team: miami_nba2022, player: miami55, price_cents: 800, shirt_number: 55
Teams::Player.create seasons_team: miami_nba2022, player: miami17, price_cents: 600, shirt_number: 17
Teams::Player.create seasons_team: philadelphia_nba2022, player: philadelphia21, price_cents: 1_250, shirt_number: 21
Teams::Player.create seasons_team: philadelphia_nba2022, player: philadelphia20, price_cents: 400, shirt_number: 20
Teams::Player.create seasons_team: philadelphia_nba2022, player: philadelphia30, price_cents: 400, shirt_number: 30
Teams::Player.create seasons_team: chicago_nba2022, player: chicago9, price_cents: 1_100, shirt_number: 9
Teams::Player.create seasons_team: chicago_nba2022, player: chicago2, price_cents: 900, shirt_number: 2
Teams::Player.create seasons_team: chicago_nba2022, player: chicago11, price_cents: 1_100, shirt_number: 11
Teams::Player.create seasons_team: boston_nba2022, player: boston0, price_cents: 1_200, shirt_number: 0
Teams::Player.create seasons_team: boston_nba2022, player: boston42, price_cents: 1_150, shirt_number: 42
Teams::Player.create seasons_team: boston_nba2022, player: boston36, price_cents: 800, shirt_number: 36
Teams::Player.create seasons_team: phoenix_nba2022, player: phoenix3, price_cents: 1_250, shirt_number: 3
Teams::Player.create seasons_team: phoenix_nba2022, player: phoenix25, price_cents: 500, shirt_number: 25
Teams::Player.create seasons_team: phoenix_nba2022, player: phoenix99, price_cents: 700, shirt_number: 99
Teams::Player.create seasons_team: golden_state_nba2022, player: golden_state30, price_cents: 2_000, shirt_number: 30
Teams::Player.create seasons_team: golden_state_nba2022, player: golden_state22, price_cents: 1_250, shirt_number: 22
Teams::Player.create seasons_team: golden_state_nba2022, player: golden_state32, price_cents: 400, shirt_number: 32
Teams::Player.create seasons_team: dallas_nba2022, player: dallas77, price_cents: 700, shirt_number: 77
Teams::Player.create seasons_team: dallas_nba2022, player: dallas13, price_cents: 350, shirt_number: 13
Teams::Player.create seasons_team: dallas_nba2022, player: dallas25, price_cents: 700, shirt_number: 25
Teams::Player.create seasons_team: lal_nba2022, player: lal6, price_cents: 1_750, shirt_number: 6
Teams::Player.create seasons_team: lal_nba2022, player: lal3, price_cents: 1_500, shirt_number: 3
Teams::Player.create seasons_team: lal_nba2022, player: lal0, price_cents: 2_000, shirt_number: 0
Teams::Player.create seasons_team: denver_nba2022, player: denver15, price_cents: 1_250, shirt_number: 15
Teams::Player.create seasons_team: denver_nba2022, player: denver50, price_cents: 800, shirt_number: 50
Teams::Player.create seasons_team: denver_nba2022, player: denver11, price_cents: 650, shirt_number: 11
Teams::Player.create seasons_team: brooklyn_nba2022, player: brooklyn13, price_cents: 1_750, shirt_number: 13
Teams::Player.create seasons_team: brooklyn_nba2022, player: brooklyn7, price_cents: 1_750, shirt_number: 7
Teams::Player.create seasons_team: brooklyn_nba2022, player: brooklyn11, price_cents: 1_250, shirt_number: 11
Teams::Player.create seasons_team: charlotte_nba2022, player: charlotte2, price_cents: 650, shirt_number: 2
Teams::Player.create seasons_team: charlotte_nba2022, player: charlotte20, price_cents: 1_200, shirt_number: 20
Teams::Player.create seasons_team: indiana_nba2022, player: indiana10, price_cents: 1_000, shirt_number: 10
Teams::Player.create seasons_team: indiana_nba2022, player: indiana7, price_cents: 1_000, shirt_number: 7
Teams::Player.create seasons_team: toronto_nba2022, player: toronto9, price_cents: 900, shirt_number: 9
Teams::Player.create seasons_team: washington_nba2022, player: washington33, price_cents: 500, shirt_number: 33
Teams::Player.create seasons_team: minnesota_nba2022, player: minnesota1, price_cents: 700, shirt_number: 1
Teams::Player.create seasons_team: memphis_nba2022, player: memphis4, price_cents: 1_250, shirt_number: 4
Teams::Player.create seasons_team: memphis_nba2022, player: memphis12, price_cents: 700, shirt_number: 12
Teams::Player.create seasons_team: cleveland_nba2022, player: cleveland24, price_cents: 600, shirt_number: 24
Teams::Player.create seasons_team: cleveland_nba2022, player: cleveland31, price_cents: 500, shirt_number: 31
Teams::Player.create seasons_team: utah_nba2022, player: utah27, price_cents: 1_200, shirt_number: 27
Teams::Player.create seasons_team: utah_nba2022, player: utah44, price_cents: 900, shirt_number: 44
Teams::Player.create seasons_team: atlanta_nba2022, player: atlanta11, price_cents: 550, shirt_number: 11

week1 = nba2022.weeks.create position: 1, status: 'coming', deadline_at: DateTime.new(2021, 10, 19, 22, 0, 0)
week2 = nba2022.weeks.create position: 2, deadline_at: DateTime.new(2021, 10, 25, 22, 0, 0)
week3 = nba2022.weeks.create position: 3, deadline_at: DateTime.new(2021, 11, 1, 22, 0, 0)
week4 = nba2022.weeks.create position: 4, deadline_at: DateTime.new(2021, 11, 8, 22, 0, 0)
week5 = nba2022.weeks.create position: 5, deadline_at: DateTime.new(2021, 11, 15, 22, 0, 0)
week6 = nba2022.weeks.create position: 6, deadline_at: DateTime.new(2021, 11, 22, 22, 0, 0)

nba2022.teams.each.with_index do |team, team_index|
  team_fantasy_league = team.fantasy_leagues.last
  10.times do |index|
    user = Users::CreateService.call(params: { email: "basketball-team-#{team_index}-#{index}@gmail.com", password: '1234qwerQWER', password_confirmation: '1234qwerQWER' }, with_send_confirmation: false).result
    FantasyTeams::GenerateSampleService.call(season: nba2022, user: user, favourite_team_uuid: team.uuid)
  end
end

Games::CreateService.call(
  week_id:                week1.id,
  home_season_team_id:    milwaukee_nba2022.id,
  visitor_season_team_id: brooklyn_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473410',
  start_at:               DateTime.new(2021, 10, 19, 23, 30, 0)
)

Games::CreateService.call(
  week_id:                week1.id,
  home_season_team_id:    lal_nba2022.id,
  visitor_season_team_id: golden_state_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473409',
  start_at:               DateTime.new(2021, 10, 20, 2, 0, 0)
)

Games::CreateService.call(
  week_id:                week1.id,
  home_season_team_id:    detroit_nba2022.id,
  visitor_season_team_id: chicago_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473412',
  start_at:               DateTime.new(2021, 10, 20, 23, 0, 0)
)

Games::CreateService.call(
  week_id:                week1.id,
  home_season_team_id:    charlotte_nba2022.id,
  visitor_season_team_id: indiana_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473411',
  start_at:               DateTime.new(2021, 10, 20, 23, 30, 0)
)

Games::CreateService.call(
  week_id:                week1.id,
  home_season_team_id:    toronto_nba2022.id,
  visitor_season_team_id: washington_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473413',
  start_at:               DateTime.new(2021, 10, 20, 23, 30, 0)
)

Games::CreateService.call(
  week_id:                week1.id,
  home_season_team_id:    knicks_nba2022.id,
  visitor_season_team_id: boston_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473414',
  start_at:               DateTime.new(2021, 10, 20, 23, 30, 0)
)

Games::CreateService.call(
  week_id:                week1.id,
  home_season_team_id:    minnesota_nba2022.id,
  visitor_season_team_id: houston_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473416',
  start_at:               DateTime.new(2021, 10, 21, 0, 0, 0)
)

Games::CreateService.call(
  week_id:                week1.id,
  home_season_team_id:    memphis_nba2022.id,
  visitor_season_team_id: cleveland_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473415',
  start_at:               DateTime.new(2021, 10, 21, 0, 0, 0)
)

Games::CreateService.call(
  week_id:                week1.id,
  home_season_team_id:    pelicans_nba2022.id,
  visitor_season_team_id: philadelphia_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473417',
  start_at:               DateTime.new(2021, 10, 21, 0, 0, 0)
)

Games::CreateService.call(
  week_id:                week1.id,
  home_season_team_id:    spurs_nba2022.id,
  visitor_season_team_id: orlando_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473418',
  start_at:               DateTime.new(2021, 10, 21, 0, 30, 0)
)

Games::CreateService.call(
  week_id:                week1.id,
  home_season_team_id:    utah_nba2022.id,
  visitor_season_team_id: oklahoma_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473419',
  start_at:               DateTime.new(2021, 10, 21, 1, 0, 0)
)

Games::CreateService.call(
  week_id:                week1.id,
  home_season_team_id:    portland_nba2022.id,
  visitor_season_team_id: sacramento_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473420',
  start_at:               DateTime.new(2021, 10, 21, 2, 0, 0)
)

Games::CreateService.call(
  week_id:                week1.id,
  home_season_team_id:    phoenix_nba2022.id,
  visitor_season_team_id: denver_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473421',
  start_at:               DateTime.new(2021, 10, 21, 2, 0, 0)
)

Games::CreateService.call(
  week_id:                week1.id,
  home_season_team_id:    atlanta_nba2022.id,
  visitor_season_team_id: dallas_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473424',
  start_at:               DateTime.new(2021, 10, 21, 23, 30, 0)
)

Games::CreateService.call(
  week_id:                week1.id,
  home_season_team_id:    golden_state_nba2022.id,
  visitor_season_team_id: lac_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473422',
  start_at:               DateTime.new(2021, 10, 22, 2, 0, 0)
)

Games::CreateService.call(
  week_id:                week1.id,
  home_season_team_id:    washington_nba2022.id,
  visitor_season_team_id: indiana_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473426',
  start_at:               DateTime.new(2021, 10, 22, 23, 0, 0)
)

Games::CreateService.call(
  week_id:                week1.id,
  home_season_team_id:    orlando_nba2022.id,
  visitor_season_team_id: knicks_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473431',
  start_at:               DateTime.new(2021, 10, 22, 23, 0, 0)
)

Games::CreateService.call(
  week_id:                week1.id,
  home_season_team_id:    miami_nba2022.id,
  visitor_season_team_id: milwaukee_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473423',
  start_at:               DateTime.new(2021, 10, 22, 0, 0, 0)
)

Games::CreateService.call(
  week_id:                week1.id,
  home_season_team_id:    lal_nba2022.id,
  visitor_season_team_id: phoenix_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473432',
  start_at:               DateTime.new(2021, 10, 23, 2, 0, 0)
)

Games::CreateService.call(
  week_id:                week2.id,
  home_season_team_id:    denver_nba2022.id,
  visitor_season_team_id: dallas_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473482',
  start_at:               DateTime.new(2021, 10, 30, 2, 0, 0)
)

Games::CreateService.call(
  week_id:                week2.id,
  home_season_team_id:    knicks_nba2022.id,
  visitor_season_team_id: philadelphia_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473461',
  start_at:               DateTime.new(2021, 10, 26, 23, 30, 0)
)

Games::CreateService.call(
  week_id:                week2.id,
  home_season_team_id:    oklahoma_nba2022.id,
  visitor_season_team_id: golden_state_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473459',
  start_at:               DateTime.new(2021, 10, 27, 0, 0, 0)
)

Games::CreateService.call(
  week_id:                week2.id,
  home_season_team_id:    dallas_nba2022.id,
  visitor_season_team_id: houston_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473458',
  start_at:               DateTime.new(2021, 10, 27, 0, 30, 0)
)

Games::CreateService.call(
  week_id:                week2.id,
  home_season_team_id:    spurs_nba2022.id,
  visitor_season_team_id: lal_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473460',
  start_at:               DateTime.new(2021, 10, 27, 0, 30, 0)
)

Games::CreateService.call(
  week_id:                week2.id,
  home_season_team_id:    utah.id,
  visitor_season_team_id: denver_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473462',
  start_at:               DateTime.new(2021, 10, 27, 2, 0, 0)
)

Games::CreateService.call(
  week_id:                week2.id,
  home_season_team_id:    brooklyn_nba2022.id,
  visitor_season_team_id: miami_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473470',
  start_at:               DateTime.new(2021, 10, 27, 23, 30, 0)
)

Games::CreateService.call(
  week_id:                week3.id,
  home_season_team_id:    boston_nba2022.id,
  visitor_season_team_id: chicago_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473507',
  start_at:               DateTime.new(2021, 11, 1, 23, 30, 0)
)

Games::CreateService.call(
  week_id:                week3.id,
  home_season_team_id:    indiana_nba2022.id,
  visitor_season_team_id: spurs_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473504',
  start_at:               DateTime.new(2021, 11, 1, 23, 0, 0)
)

Games::CreateService.call(
  week_id:                week3.id,
  home_season_team_id:    philadelphia_nba2022.id,
  visitor_season_team_id: portland_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473503',
  start_at:               DateTime.new(2021, 11, 1, 23, 0, 0)
)

Games::CreateService.call(
  week_id:                week3.id,
  home_season_team_id:    knicks_nba2022.id,
  visitor_season_team_id: toronto_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473502',
  start_at:               DateTime.new(2021, 11, 1, 23, 30, 0)
)

Games::CreateService.call(
  week_id:                week3.id,
  home_season_team_id:    lal_nba2022.id,
  visitor_season_team_id: houston_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473498',
  start_at:               DateTime.new(2021, 11, 3, 2, 30, 0)
)

Games::CreateService.call(
  week_id:                week3.id,
  home_season_team_id:    cleveland_nba2022.id,
  visitor_season_team_id: portland_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473520',
  start_at:               DateTime.new(2021, 11, 3, 23, 0, 0)
)

Games::CreateService.call(
  week_id:                week4.id,
  home_season_team_id:    philadelphia_nba2022.id,
  visitor_season_team_id: knicks_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473560',
  start_at:               DateTime.new(2021, 11, 9, 0, 0, 0)
)

Games::CreateService.call(
  week_id:                week4.id,
  home_season_team_id:    chicago_nba2022.id,
  visitor_season_team_id: brooklyn_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473561',
  start_at:               DateTime.new(2021, 11, 9, 1, 0, 0)
)

Games::CreateService.call(
  week_id:                week4.id,
  home_season_team_id:    memphis_nba2022.id,
  visitor_season_team_id: minnesota_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473557',
  start_at:               DateTime.new(2021, 11, 9, 1, 0, 0)
)

Games::CreateService.call(
  week_id:                week4.id,
  home_season_team_id:    dallas_nba2022.id,
  visitor_season_team_id: pelicans_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473556',
  start_at:               DateTime.new(2021, 11, 9, 1, 30, 0)
)

Games::CreateService.call(
  week_id:                week4.id,
  home_season_team_id:    denver_nba2022.id,
  visitor_season_team_id: miami_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473558',
  start_at:               DateTime.new(2021, 11, 9, 2, 0, 0)
)

Games::CreateService.call(
  week_id:                week4.id,
  home_season_team_id:    golden_state_nba2022.id,
  visitor_season_team_id: atlanta_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473555',
  start_at:               DateTime.new(2021, 11, 9, 3, 0, 0)
)

Games::CreateService.call(
  week_id:                week5.id,
  home_season_team_id:    cleveland_nba2022.id,
  visitor_season_team_id: boston_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473608',
  start_at:               DateTime.new(2021, 11, 16, 0, 0, 0)
)

Games::CreateService.call(
  week_id:                week5.id,
  home_season_team_id:    detroit_nba2022.id,
  visitor_season_team_id: sacramento_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473613',
  start_at:               DateTime.new(2021, 11, 16, 0, 0, 0)
)

Games::CreateService.call(
  week_id:                week5.id,
  home_season_team_id:    washington_nba2022.id,
  visitor_season_team_id: pelicans_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473615',
  start_at:               DateTime.new(2021, 11, 16, 0, 0, 0)
)

Games::CreateService.call(
  week_id:                week5.id,
  home_season_team_id:    knicks_nba2022.id,
  visitor_season_team_id: indiana_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473611',
  start_at:               DateTime.new(2021, 11, 16, 0, 30, 0)
)

Games::CreateService.call(
  week_id:                week5.id,
  home_season_team_id:    atlanta_nba2022.id,
  visitor_season_team_id: orlando_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473607',
  start_at:               DateTime.new(2021, 11, 16, 0, 30, 0)
)

Games::CreateService.call(
  week_id:                week5.id,
  home_season_team_id:    lal_nba2022.id,
  visitor_season_team_id: chicago_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473617',
  start_at:               DateTime.new(2021, 11, 16, 3, 30, 0)
)

Games::CreateService.call(
  week_id:                week6.id,
  home_season_team_id:    washington_nba2022.id,
  visitor_season_team_id: charlotte_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473667',
  start_at:               DateTime.new(2021, 11, 23, 0, 0, 0)
)

Games::CreateService.call(
  week_id:                week6.id,
  home_season_team_id:    boston_nba2022.id,
  visitor_season_team_id: houston_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473664',
  start_at:               DateTime.new(2021, 11, 23, 0, 30, 0)
)

Games::CreateService.call(
  week_id:                week6.id,
  home_season_team_id:    knicks_nba2022.id,
  visitor_season_team_id: lal_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473671',
  start_at:               DateTime.new(2021, 11, 24, 0, 30, 0)
)

Games::CreateService.call(
  week_id:                week6.id,
  home_season_team_id:    indiana_nba2022.id,
  visitor_season_team_id: lal_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473680',
  start_at:               DateTime.new(2021, 11, 25, 0, 0, 0)
)

Games::CreateService.call(
  week_id:                week6.id,
  home_season_team_id:    cleveland_nba2022.id,
  visitor_season_team_id: phoenix_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473675',
  start_at:               DateTime.new(2021, 11, 25, 0, 0, 0)
)

Games::CreateService.call(
  week_id:                week6.id,
  home_season_team_id:    boston_nba2022.id,
  visitor_season_team_id: brooklyn_nba2022.id,
  source:                 Sourceable::BALLDONTLIE,
  external_id:            '473677',
  start_at:               DateTime.new(2021, 11, 25, 0, 30, 0)
)
