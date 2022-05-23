nba = League.create(sport_kind: 'basketball', name: { en: 'NBA', ru: 'НБА' })

nba2022 = nba.seasons.create name: '2021/2022', active: true

overall_fantasy_nba_league = nba2022.all_fantasy_leagues.create leagueable: nba2022, name: 'Overall', global: true

milwaukee = Team.create name: { en: 'Milwaukee Bucks', ru: 'Милуоки Бакс' }, short_name: 'MIL'
miami = Team.create name: { en: 'Miami Heat', ru: 'Майами Хит' }, short_name: 'MIA'
philadelphia = Team.create name: { en: 'Philadelphia 76ers', ru: 'Филадельфия Сиксерс' }, short_name: 'PHI'
chicago = Team.create name: { en: 'Chicago Bulls', ru: 'Чикаго Буллз' }, short_name: 'CHI'
boston = Team.create name: { en: 'Boston Celtics', ru: 'Бостон Селтикс' }, short_name: 'BOS'

phoenix = Team.create name: { en: 'Phoenix Suns', ru: 'Финикс Санз' }, short_name: 'PHX'
golden_state = Team.create name: { en: 'Golden State Warriors', ru: 'Голден Стэйт Уорриорз' }, short_name: 'GSW'
dallas = Team.create name: { en: 'Dallas Mavericks', ru: 'Даллас Маверикс' }, short_name: 'DAL'
lal = Team.create name: { en: 'Los Angeles Lakers', ru: 'Лос-Анджелес Лейкерс' }, short_name: 'LAL'
denver = Team.create name: { en: 'Denver Nuggets', ru: 'Денвер Наггетс' }, short_name: 'DEN'

nba2022.all_fantasy_leagues.create leagueable: milwaukee, name: 'Milwaukee Bucks', global: true
nba2022.all_fantasy_leagues.create leagueable: miami, name: 'Miami Heat', global: true
nba2022.all_fantasy_leagues.create leagueable: philadelphia, name: 'Philadelphia 76ers', global: true
nba2022.all_fantasy_leagues.create leagueable: chicago, name: 'Chicago Bulls', global: true
nba2022.all_fantasy_leagues.create leagueable: boston, name: 'Boston Celtics', global: true
nba2022.all_fantasy_leagues.create leagueable: phoenix, name: 'Phoenix Suns', global: true
nba2022.all_fantasy_leagues.create leagueable: golden_state, name: 'Golden State Warriors', global: true
nba2022.all_fantasy_leagues.create leagueable: dallas, name: 'Dallas Mavericks', global: true
nba2022.all_fantasy_leagues.create leagueable: lal, name: 'Los Angeles Lakers', global: true
nba2022.all_fantasy_leagues.create leagueable: denver, name: 'Denver Nuggets', global: true

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

week1 = nba2022.weeks.create position: 1, status: 'coming', deadline_at: DateTime.new(2021, 10, 19, 8, 0, 0)
week2 = nba2022.weeks.create position: 2, deadline_at: DateTime.new(2021, 10, 29, 12, 0, 0)
week3 = nba2022.weeks.create position: 3, deadline_at: DateTime.new(2021, 11, 1, 13, 0, 0)

nba2022.teams.each.with_index do |team, team_index|
  team_fantasy_league = team.fantasy_leagues.last
  10.times do |index|
    user = Users::CreateService.call(params: { email: "basketball-team-#{team_index}-#{index}@gmail.com", password: '1234qwerQWER', password_confirmation: '1234qwerQWER' }).result
    FantasyTeams::GenerateService.call(season: nba2022, user: user, favourite_team_id: team.id)
  end
end

Games::CreateService.call(
  week:                week1,
  home_season_team:    lal_nba2022,
  visitor_season_team: golden_state_nba2022,
  source:              Sourceable::BALLDONTLIE,
  external_id:         '473409',
  start_at:            DateTime.new(2021, 10, 19, 10, 0, 0)
)

Games::CreateService.call(
  week:                week1,
  home_season_team:    phoenix_nba2022,
  visitor_season_team: denver_nba2022,
  source:              Sourceable::BALLDONTLIE,
  external_id:         '473421',
  start_at:            DateTime.new(2021, 10, 20, 11, 0, 0)
)

Games::CreateService.call(
  week:                week1,
  home_season_team:    miami_nba2022,
  visitor_season_team: milwaukee_nba2022,
  source:              Sourceable::BALLDONTLIE,
  external_id:         '473423',
  start_at:            DateTime.new(2021, 10, 21, 12, 0, 0)
)

Games::CreateService.call(
  week:                week1,
  home_season_team:    lal_nba2022,
  visitor_season_team: phoenix_nba2022,
  source:              Sourceable::BALLDONTLIE,
  external_id:         '473432',
  start_at:            DateTime.new(2021, 10, 22, 13, 0, 0)
)

Games::CreateService.call(
  week:                week2,
  home_season_team:    denver_nba2022,
  visitor_season_team: dallas_nba2022,
  source:              Sourceable::BALLDONTLIE,
  external_id:         '473482',
  start_at:            DateTime.new(2021, 10, 29, 14, 0, 0)
)

Games::CreateService.call(
  week:                week3,
  home_season_team:    boston_nba2022,
  visitor_season_team: chicago_nba2022,
  source:              Sourceable::BALLDONTLIE,
  external_id:         '473507',
  start_at:            DateTime.new(2021, 11, 1, 15, 0, 0)
)
