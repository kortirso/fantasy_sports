rpl = League.create(sport_kind: 'football', name: { en: 'Russian Premier Liga', ru: 'Российская Премьер-Лига' })

rpl2022 = rpl.seasons.create name: '2021/2022', active: true

overall_fantasy_rpl_league = rpl2022.all_fantasy_leagues.create leagueable: rpl2022, name: 'Overall', global: true

spartak = Team.create name: { en: 'Spartak', ru: 'Спартак' }, short_name: 'СПАР'
zenit = Team.create name: { en: 'Zenit', ru: 'Зенит' }, short_name: 'ЗЕН'
lokomotiv = Team.create name: { en: 'Lokomotiv', ru: 'Локомотив' }, short_name: 'ЛОК'
cska = Team.create name: { en: 'CSKA', ru: 'ЦСКА' }, short_name: 'ЦСКА'
dinamo = Team.create name: { en: 'Dinamo', ru: 'Динамо' }, short_name: 'ДИН'
sochi = Team.create name: { en: 'Sochi', ru: 'Сочи' }, short_name: 'СОЧ'
krasnodar = Team.create name: { en: 'Krasnodar', ru: 'Краснодар' }, short_name: 'КРАС'
rubin = Team.create name: { en: 'Rubin', ru: 'Рубин' }, short_name: 'РУБ'
khimki = Team.create name: { en: 'Khimki', ru: 'Химки' }, short_name: 'ХИМ'
rostov = Team.create name: { en: 'Rostov', ru: 'Ростов' }, short_name: 'РОСТ'
akhmat = Team.create name: { en: 'Akhmat', ru: 'Ахмат' }, short_name: 'АХМ'
ural = Team.create name: { en: 'Ural', ru: 'Урал' }, short_name: 'УРАЛ'
ufa = Team.create name: { en: 'Ufa', ru: 'Уфа' }, short_name: 'УФА'
arsenal = Team.create name: { en: 'Arsenal', ru: 'Арсенал' }, short_name: 'АРС'
krylia = Team.create name: { en: 'Krylia Sovetov', ru: 'Крылья Советов' }, short_name: 'КРЛ'
novgorod = Team.create name: { en: 'Nizhny Novgorod', ru: 'Нижний Новгород' }, short_name: 'НОВГ'

team1_fantasy_rpl_league = rpl2022.all_fantasy_leagues.create leagueable: spartak, name: 'Спартак', global: true
team2_fantasy_rpl_league = rpl2022.all_fantasy_leagues.create leagueable: zenit, name: 'Зенит', global: true
team3_fantasy_rpl_league = rpl2022.all_fantasy_leagues.create leagueable: lokomotiv, name: 'Локомотив', global: true
team4_fantasy_rpl_league = rpl2022.all_fantasy_leagues.create leagueable: cska, name: 'ЦСКА', global: true
team5_fantasy_rpl_league = rpl2022.all_fantasy_leagues.create leagueable: dinamo, name: 'Динамо', global: true
team6_fantasy_rpl_league = rpl2022.all_fantasy_leagues.create leagueable: sochi, name: 'Сочи', global: true
team7_fantasy_rpl_league = rpl2022.all_fantasy_leagues.create leagueable: krasnodar, name: 'Краснодар', global: true
team8_fantasy_rpl_league = rpl2022.all_fantasy_leagues.create leagueable: rubin, name: 'Рубин', global: true
team9_fantasy_rpl_league = rpl2022.all_fantasy_leagues.create leagueable: khimki, name: 'Химки', global: true
team10_fantasy_rpl_league = rpl2022.all_fantasy_leagues.create leagueable: rostov, name: 'Ростов', global: true
team11_fantasy_rpl_league = rpl2022.all_fantasy_leagues.create leagueable: akhmat, name: 'Ахмат', global: true
team12_fantasy_rpl_league = rpl2022.all_fantasy_leagues.create leagueable: ural, name: 'Урал', global: true
team13_fantasy_rpl_league = rpl2022.all_fantasy_leagues.create leagueable: ufa, name: 'Уфа', global: true
team14_fantasy_rpl_league = rpl2022.all_fantasy_leagues.create leagueable: arsenal, name: 'Арсенал', global: true
team15_fantasy_rpl_league = rpl2022.all_fantasy_leagues.create leagueable: krylia, name: 'Крылья Советов', global: true
team16_fantasy_rpl_league = rpl2022.all_fantasy_leagues.create leagueable: novgorod, name: 'Нижний Новгород', global: true

spartak_rpl2022 = Seasons::Team.create team: spartak, season: rpl2022
zenit_rpl2022 = Seasons::Team.create team: zenit, season: rpl2022
lokomotiv_rpl2022 = Seasons::Team.create team: lokomotiv, season: rpl2022
cska_rpl2022 = Seasons::Team.create team: cska, season: rpl2022
dinamo_rpl2022 = Seasons::Team.create team: dinamo, season: rpl2022
sochi_rpl2022 = Seasons::Team.create team: sochi, season: rpl2022
krasnodar_rpl2022 = Seasons::Team.create team: krasnodar, season: rpl2022
rubin_rpl2022 = Seasons::Team.create team: rubin, season: rpl2022
khimki_rpl2022 = Seasons::Team.create team: khimki, season: rpl2022
rostov_rpl2022 = Seasons::Team.create team: rostov, season: rpl2022
akhmat_rpl2022 = Seasons::Team.create team: akhmat, season: rpl2022
ural_rpl2022 = Seasons::Team.create team: ural, season: rpl2022
ufa_rpl2022 = Seasons::Team.create team: ufa, season: rpl2022
arsenal_rpl2022 = Seasons::Team.create team: arsenal, season: rpl2022
krylia_rpl2022 = Seasons::Team.create team: krylia, season: rpl2022
novgorod_rpl2022 = Seasons::Team.create team: novgorod, season: rpl2022

rostov30 = Player.create position_kind: 'football_goalkeeper', name: { en: 'Pesyakov Sergey', ru: 'Песьяков Сергей' }
rostov4 = Player.create position_kind: 'football_defender', name: { en: 'Terentyev Denis', ru: 'Терентьев Денис' }
rostov55 = Player.create position_kind: 'football_defender', name: { en: 'Osipenko Maxim', ru: 'Осипенко Максим' }
rostov13 = Player.create position_kind: 'football_defender', name: { en: 'Kalinin Igor', ru: 'Калинин Игорь' }
rostov5 = Player.create position_kind: 'football_defender', name: { en: 'Hadzikadunic Dennis', ru: 'Хаджикадунич Деннис' }
rostov87 = Player.create position_kind: 'football_defender', name: { en: 'Langovich Andrey', ru: 'Лангович Андрей' }
rostov19 = Player.create position_kind: 'football_midfielder', name: { en: 'Bairamyan Khoren', ru: 'Байрамян Хорен' }
rostov15 = Player.create position_kind: 'football_midfielder', name: { en: 'Glebov Danil', ru: 'Глебов Данил' }
rostov76 = Player.create position_kind: 'football_midfielder', name: { en: 'Sukhomlinov Danila', ru: 'Сухомлинов Данила' }
rostov18 = Player.create position_kind: 'football_midfielder', name: { en: 'Hashimoto Kento', ru: 'Хашимото Кенто' }
rostov10 = Player.create position_kind: 'football_midfielder', name: { en: 'Mamaev Pavel', ru: 'Мамаев Павел' }
rostov25 = Player.create position_kind: 'football_midfielder', name: { en: 'Folmer Kirill', ru: 'Фольмер Кирилл' }
rostov11 = Player.create position_kind: 'football_midfielder', name: { en: 'Almqvist Pontus', ru: 'Алмквист Понтус' }
rostov8 = Player.create position_kind: 'football_midfielder', name: { en: 'Gigovic Armin', ru: 'Гигович Армин' }
rostov27 = Player.create position_kind: 'football_forward', name: { en: 'Komlichenko Nikolay', ru: 'Комличенко Николай' }
rostov7 = Player.create position_kind: 'football_forward', name: { en: 'Poloz Dmitry', ru: 'Полоз Дмитрий' }

dinamo1 = Player.create position_kind: 'football_goalkeeper', name: { en: 'Shunin Anton', ru: 'Шунин Антон' }
dinamo4 = Player.create position_kind: 'football_defender', name: { en: 'Parshivlyuk Sergey', ru: 'Паршивлюк Сергей' }
dinamo18 = Player.create position_kind: 'football_defender', name: { en: 'Ordets Ivan', ru: 'Ордец Иван' }
dinamo93 = Player.create position_kind: 'football_defender', name: { en: "Laksal't Diego", ru: 'Лаксальт Диего' }
dinamo5 = Player.create position_kind: 'football_defender', name: { en: 'Balbuena Fabián', ru: 'Бальбуэна Фабиан' }
dinamo50 = Player.create position_kind: 'football_defender', name: { en: 'Kutitskiy Alexander', ru: 'Кутицкий Александр' }
dinamo7 = Player.create position_kind: 'football_defender', name: { en: 'Skopincev Dmitry', ru: 'Скопинцев Дмитрий' }
dinamo74 = Player.create position_kind: 'football_midfielder', name: { en: 'Fomin Daniil', ru: 'Фомин Даниил' }
dinamo19 = Player.create position_kind: 'football_midfielder', name: { en: 'Lesovoy Daniil', ru: 'Лесовой Даниил' }
dinamo47 = Player.create position_kind: 'football_midfielder', name: { en: 'Zakharyan Arsen', ru: 'Захарян Арсен' }
dinamo53 = Player.create position_kind: 'football_midfielder', name: { en: 'Szymanski Sebastian', ru: 'Шиманьски Себастиан' }
dinamo8 = Player.create position_kind: 'football_midfielder', name: { en: 'Moro Nikola', ru: 'Моро Никола' }
dinamo70 = Player.create position_kind: 'football_forward', name: { en: 'Tyukavin Konstantin', ru: 'Тюкавин Константин' }
dinamo10 = Player.create position_kind: 'football_forward', name: { en: 'Igboun Sylvester', ru: 'Игбун Сильвестр' }
dinamo9 = Player.create position_kind: 'football_forward', name: { en: 'Njie Clinton', ru: "Н'Жи Клинтон" }

maksimenko = Player.create position_kind: 'football_goalkeeper', name: { en: 'Maksimenko Alexander', ru: 'Максименко Александр' }
guilherme = Player.create position_kind: 'football_goalkeeper', name: { en: 'Guilherme Marinato', ru: 'Гилерме Маринато' }
akinfeev = Player.create position_kind: 'football_goalkeeper', name: { en: 'Akinfeev Igor', ru: 'Акинфеев Игорь' }
safonov = Player.create position_kind: 'football_goalkeeper', name: { en: 'Safonov Matvey', ru: 'Сафонов Матвей' }

rakitskyi = Player.create position_kind: 'football_defender', name: { en: 'Rakitskyi Yaroslav', ru: 'Ракицкий Ярослав' }
lovren = Player.create position_kind: 'football_defender', name: { en: 'Lovren Dejan', ru: 'Ловрен Деян' }
dzhikiia = Player.create position_kind: 'football_defender', name: { en: 'Dzhikiia Georgy', ru: 'Джикия Георгий' }
fernandes = Player.create position_kind: 'football_defender', name: { en: 'Fernandes Mario', ru: 'Фернандес Марио' }
gigot = Player.create position_kind: 'football_defender', name: { en: 'Gigot Samuel', ru: 'Жиго Самуэль' }
karavaev = Player.create position_kind: 'football_defender', name: { en: 'Karavaev Vyacheslav', ru: 'Караваев Вячеслав' }
diveev = Player.create position_kind: 'football_defender', name: { en: 'Diveev Igor', ru: 'Дивеев Игорь' }

ozdoev = Player.create position_kind: 'football_midfielder', name: { en: 'Ozdoev Magomed', ru: 'Оздоев Магомед' }
zobnin = Player.create position_kind: 'football_midfielder', name: { en: 'Zobnin Roman', ru: 'Зобнин Роман' }
zhemaletdinov = Player.create position_kind: 'football_midfielder', name: { en: 'Zhemaletdinov Rifat', ru: 'Жемалетдинов Рифат' }
dzagoev = Player.create position_kind: 'football_midfielder', name: { en: 'Dzagoev Alan', ru: 'Дзагоев Алан' }
mostovoy = Player.create position_kind: 'football_midfielder', name: { en: 'Mostovoy Andrey', ru: 'Мостовой Андрей' }
barinov = Player.create position_kind: 'football_midfielder', name: { en: 'Barinov Dmitry', ru: 'Баринов Дмитрий' }
fomin = Player.create position_kind: 'football_midfielder', name: { en: 'Fomin Daniil', ru: 'Фомин Даниил' }
bakaev = Player.create position_kind: 'football_midfielder', name: { en: 'Bakaev Zelimkhan', ru: 'Бакаев Зелимхан' }
ionov = Player.create position_kind: 'football_midfielder', name: { en: 'Ionov Alexey', ru: 'Ионов Алексей' }
sutormin = Player.create position_kind: 'football_midfielder', name: { en: 'Sutormin Alexey', ru: 'Сутормин Алексей' }

azmoun = Player.create position_kind: 'football_forward', name: { en: 'Azmoun Sardar', ru: 'Азмун Сердар' }
dzyuba = Player.create position_kind: 'football_forward', name: { en: 'Dzyuba Artem', ru: 'Дзюба Артём' }
sobolev = Player.create position_kind: 'football_forward', name: { en: 'Sobolev Alexander', ru: 'Соболев Александр' }
smolov = Player.create position_kind: 'football_forward', name: { en: 'Smolov Fyodor', ru: 'Смолов Фёдор' }
zabolotnyy = Player.create position_kind: 'football_forward', name: { en: 'Zabolotnyy Anton', ru: 'Заболотный Антон' }

### goalkeeper, maximum is 600
# price > 3_000_000 => 600
# price > 2_000_000 => 550
# price > 1_500_000 => 500
# price >= 1_000_000 => 450
# price < 1_000_000 => 400

### defenders, maximum is 750
# price >= 12_000_000 => 750
# price >= 8_000_000 => 700
# price >= 7_000_000 => 650
# price >= 6_000_000 => 600
# price >= 5_000_000 => 550
# price >= 3_000_000 => 500
# price >= 1_000_000 => 450
# price < 1_000_000 => 400

### forward, midfielder, maximum is 1_250
# price >= 20_000_000 => 1_250
# price >= 15_000_000 => 1_200
# price >= 12_000_000 => 1_100
# price >= 10_000_000 => 1_000
# price >= 9_000_000 => 950
# price >= 8_000_000 => 900
# price >= 7_000_000 => 850
# price >= 6_000_000 => 800
# price >= 5_000_000 => 750
# price >= 4_000_000 => 700
# price >= 3_000_000 => 600
# price >= 2_000_000 => 500
# price >= 1_000_000 => 450
# price < 1_000_000 => 400
Teams::Player.create seasons_team: rostov_rpl2022, player: rostov30, price_cents: 450, shirt_number: 30
Teams::Player.create seasons_team: rostov_rpl2022, player: rostov4, price_cents: 400, shirt_number: 4
Teams::Player.create seasons_team: rostov_rpl2022, player: rostov55, price_cents: 500, shirt_number: 55
Teams::Player.create seasons_team: rostov_rpl2022, player: rostov13, price_cents: 400, shirt_number: 13
Teams::Player.create seasons_team: rostov_rpl2022, player: rostov5, price_cents: 450, shirt_number: 5
Teams::Player.create seasons_team: rostov_rpl2022, player: rostov87, price_cents: 400, shirt_number: 87
Teams::Player.create seasons_team: rostov_rpl2022, player: rostov19, price_cents: 500, shirt_number: 19
Teams::Player.create seasons_team: rostov_rpl2022, player: rostov15, price_cents: 700, shirt_number: 15
Teams::Player.create seasons_team: rostov_rpl2022, player: rostov76, price_cents: 400, shirt_number: 76
Teams::Player.create seasons_team: rostov_rpl2022, player: rostov18, price_cents: 500, shirt_number: 18
Teams::Player.create seasons_team: rostov_rpl2022, player: rostov10, price_cents: 450, shirt_number: 10
Teams::Player.create seasons_team: rostov_rpl2022, player: rostov25, price_cents: 400, shirt_number: 25
Teams::Player.create seasons_team: rostov_rpl2022, player: rostov11, price_cents: 600, shirt_number: 11
Teams::Player.create seasons_team: rostov_rpl2022, player: rostov8, price_cents: 500, shirt_number: 8
Teams::Player.create seasons_team: rostov_rpl2022, player: rostov27, price_cents: 600, shirt_number: 27
Teams::Player.create seasons_team: rostov_rpl2022, player: rostov7, price_cents: 500, shirt_number: 7

Teams::Player.create seasons_team: dinamo_rpl2022, player: dinamo1, price_cents: 500, shirt_number: 1
Teams::Player.create seasons_team: dinamo_rpl2022, player: dinamo4, price_cents: 450, shirt_number: 4
Teams::Player.create seasons_team: dinamo_rpl2022, player: dinamo18, price_cents: 550, shirt_number: 18
Teams::Player.create seasons_team: dinamo_rpl2022, player: dinamo93, price_cents: 500, shirt_number: 93
Teams::Player.create seasons_team: dinamo_rpl2022, player: dinamo5, price_cents: 600, shirt_number: 5
Teams::Player.create seasons_team: dinamo_rpl2022, player: dinamo50, price_cents: 400, shirt_number: 50
Teams::Player.create seasons_team: dinamo_rpl2022, player: dinamo7, price_cents: 500, shirt_number: 7
Teams::Player.create seasons_team: dinamo_rpl2022, player: dinamo74, price_cents: 950, shirt_number: 74
Teams::Player.create seasons_team: dinamo_rpl2022, player: dinamo19, price_cents: 750, shirt_number: 19
Teams::Player.create seasons_team: dinamo_rpl2022, player: dinamo47, price_cents: 1_100, shirt_number: 47
Teams::Player.create seasons_team: dinamo_rpl2022, player: dinamo53, price_cents: 1_100, shirt_number: 53
Teams::Player.create seasons_team: dinamo_rpl2022, player: dinamo8, price_cents: 950, shirt_number: 8
Teams::Player.create seasons_team: dinamo_rpl2022, player: dinamo70, price_cents: 850, shirt_number: 70
Teams::Player.create seasons_team: dinamo_rpl2022, player: dinamo10, price_cents: 450, shirt_number: 10
Teams::Player.create seasons_team: dinamo_rpl2022, player: dinamo9, price_cents: 450, shirt_number: 9

Teams::Player.create seasons_team: spartak_rpl2022, player: maksimenko, price_cents: 600
Teams::Player.create seasons_team: lokomotiv_rpl2022, player: guilherme, price_cents: 450, shirt_number: 1
Teams::Player.create seasons_team: cska_rpl2022, player: akinfeev, price_cents: 550, shirt_number: 35
Teams::Player.create seasons_team: krasnodar_rpl2022, player: safonov, price_cents: 600
Teams::Player.create seasons_team: zenit_rpl2022, player: rakitskyi, price_cents: 600
Teams::Player.create seasons_team: zenit_rpl2022, player: lovren, price_cents: 650
Teams::Player.create seasons_team: zenit_rpl2022, player: karavaev, price_cents: 650
Teams::Player.create seasons_team: spartak_rpl2022, player: dzhikiia, price_cents: 700
Teams::Player.create seasons_team: cska_rpl2022, player: fernandes, price_cents: 750
Teams::Player.create seasons_team: spartak_rpl2022, player: gigot, price_cents: 700
Teams::Player.create seasons_team: cska_rpl2022, player: diveev, price_cents: 600
Teams::Player.create seasons_team: zenit_rpl2022, player: ozdoev, price_cents: 700
Teams::Player.create seasons_team: spartak_rpl2022, player: zobnin, price_cents: 1_000
Teams::Player.create seasons_team: lokomotiv_rpl2022, player: zhemaletdinov, price_cents: 850
Teams::Player.create seasons_team: lokomotiv_rpl2022, player: barinov, price_cents: 1_100
Teams::Player.create seasons_team: dinamo_rpl2022, player: fomin, price_cents: 950
Teams::Player.create seasons_team: cska_rpl2022, player: dzagoev, price_cents: 500
Teams::Player.create seasons_team: zenit_rpl2022, player: mostovoy, price_cents: 600
Teams::Player.create seasons_team: spartak_rpl2022, player: bakaev, price_cents: 750
Teams::Player.create seasons_team: krasnodar_rpl2022, player: ionov, price_cents: 500, shirt_number: 11
Teams::Player.create seasons_team: zenit_rpl2022, player: sutormin, price_cents: 600
Teams::Player.create seasons_team: zenit_rpl2022, player: azmoun, price_cents: 1_250
Teams::Player.create seasons_team: zenit_rpl2022, player: dzyuba, price_cents: 950
Teams::Player.create seasons_team: spartak_rpl2022, player: sobolev, price_cents: 950
Teams::Player.create seasons_team: lokomotiv_rpl2022, player: smolov, price_cents: 850
Teams::Player.create seasons_team: cska_rpl2022, player: zabolotnyy, price_cents: 500

rpl2022.teams.each.with_index do |team, team_index|
  team_fantasy_league = team.fantasy_leagues.last
  10.times do |index|
    user = Users::CreateService.call(params: { email: "football-team-#{team_index}-#{index}@gmail.com", password: '1234qwerQWER', password_confirmation: '1234qwerQWER' }).result
    FantasyTeams::GenerateService.call(season: rpl2022, user: user, favourite_team_id: team.id)
  end
end

week1 = rpl2022.weeks.create position: 1, status: 'coming', deadline_at: DateTime.new(2021, 07, 23, 16, 0, 0)
week2 = rpl2022.weeks.create position: 2, deadline_at: DateTime.new(2021, 07, 30, 15, 0, 0)

Games::CreateService.call(
  week:                week1,
  home_season_team:    rostov_rpl2022,
  visitor_season_team: dinamo_rpl2022,
  source:              Sourceable::INSTAT,
  external_id:         '1966291',
  start_at:            DateTime.new(2021, 7, 23, 20, 0, 0)
)
Games::CreateService.call(
  week:                week1,
  home_season_team:    khimki_rpl2022,
  visitor_season_team: zenit_rpl2022,
  source:              Sourceable::INSTAT,
  external_id:         '1966298',
  start_at:            DateTime.new(2021, 7, 24, 17, 30, 0)
)
Games::CreateService.call(
  week:                week1,
  home_season_team:    lokomotiv_rpl2022,
  visitor_season_team: arsenal_rpl2022,
  source:              Sourceable::INSTAT,
  external_id:         '1966294',
  start_at:            DateTime.new(2021, 7, 24, 20, 0, 0)
)
Games::CreateService.call(
  week:                week1,
  home_season_team:    rubin_rpl2022,
  visitor_season_team: spartak_rpl2022,
  source:              Sourceable::INSTAT,
  external_id:         '1966295',
  start_at:            DateTime.new(2021, 7, 24, 20, 0, 0)
)
Games::CreateService.call(
  week:                week1,
  home_season_team:    ural_rpl2022,
  visitor_season_team: krasnodar_rpl2022,
  source:              Sourceable::INSTAT,
  external_id:         '1966297',
  start_at:            DateTime.new(2021, 7, 25, 17, 30, 0)
)
Games::CreateService.call(
  week:                week1,
  home_season_team:    krylia_rpl2022,
  visitor_season_team: akhmat_rpl2022,
  source:              Sourceable::INSTAT,
  external_id:         '1966292',
  start_at:            DateTime.new(2021, 7, 25, 19, 0, 0)
)
Games::CreateService.call(
  week:                week1,
  home_season_team:    cska_rpl2022,
  visitor_season_team: ufa_rpl2022,
  source:              Sourceable::INSTAT,
  external_id:         '1966293',
  start_at:            DateTime.new(2021, 7, 25, 20, 0, 0)
)
Games::CreateService.call(
  week:                week1,
  home_season_team:    novgorod_rpl2022,
  visitor_season_team: sochi_rpl2022,
  source:              Sourceable::INSTAT,
  external_id:         '1966296',
  start_at:            DateTime.new(2021, 7, 26, 19, 0, 0)
)
Games::CreateService.call(
  week:                week2,
  home_season_team:    krylia_rpl2022,
  visitor_season_team: spartak_rpl2022,
  source:              Sourceable::INSTAT,
  external_id:         '1966301',
  start_at:            DateTime.new(2021, 7, 30, 19, 0, 0)
)
Games::CreateService.call(
  week:                week2,
  home_season_team:    arsenal_rpl2022,
  visitor_season_team: rubin_rpl2022,
  source:              Sourceable::INSTAT,
  external_id:         '1966304',
  start_at:            DateTime.new(2021, 7, 30, 19, 0, 0)
)
Games::CreateService.call(
  week:                week2,
  home_season_team:    ufa_rpl2022,
  visitor_season_team: dinamo_rpl2022,
  source:              Sourceable::INSTAT,
  external_id:         '1966305',
  start_at:            DateTime.new(2021, 7, 31, 17, 30, 0)
)
Games::CreateService.call(
  week:                week2,
  home_season_team:    cska_rpl2022,
  visitor_season_team: lokomotiv_rpl2022,
  source:              Sourceable::INSTAT,
  external_id:         '1966302',
  start_at:            DateTime.new(2021, 7, 31, 20, 0, 0)
)
Games::CreateService.call(
  week:                week2,
  home_season_team:    ural_rpl2022,
  visitor_season_team: novgorod_rpl2022,
  source:              Sourceable::INSTAT,
  external_id:         '1966306',
  start_at:            DateTime.new(2021, 8, 01, 17, 30, 0)
)
Games::CreateService.call(
  week:                week2,
  home_season_team:    rostov_rpl2022,
  visitor_season_team: zenit_rpl2022,
  source:              Sourceable::INSTAT,
  external_id:         '1966299',
  start_at:            DateTime.new(2021, 8, 01, 20, 0, 0)
)
Games::CreateService.call(
  week:                week2,
  home_season_team:    krasnodar_rpl2022,
  visitor_season_team: khimki_rpl2022,
  source:              Sourceable::INSTAT,
  external_id:         '1966300',
  start_at:            DateTime.new(2021, 8, 01, 20, 0, 0)
)
Games::CreateService.call(
  week:                week2,
  home_season_team:    akhmat_rpl2022,
  visitor_season_team: sochi_rpl2022,
  source:              Sourceable::INSTAT,
  external_id:         '1966303',
  start_at:            DateTime.new(2021, 8, 02, 20, 0, 0)
)
