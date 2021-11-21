football = Sport.create name: { en: 'Football', ru: 'Футбол' }
basketball = Sport.create name: { en: 'Basketball', ru: 'Баскетбол' }
hockey = Sport.create name: { en: 'Hockey', ru: 'Хоккей' }

rpl = football.leagues.create name: { en: 'Russian Premier Liga', ru: 'Российская Премьер-Лига' }
nba = basketball.leagues.create name: { en: 'NBA', ru: 'НБА' }
nhl = hockey.leagues.create name: { en: 'NHL', ru: 'НХЛ' }

football_goalkeeper = football.sports_positions.create(
  name:            { en: 'Goalkeeper', ru: 'Вратарь' },
  total_amount:    2,
  min_game_amount: 1,
  max_game_amount: 1
)
football_defender = football.sports_positions.create(
  name:            { en: 'Defender', ru: 'Защитник' },
  total_amount:    5,
  min_game_amount: 3,
  max_game_amount: 5
)
football_midfielder = football.sports_positions.create(
  name:            { en: 'Midfielder', ru: 'Полузащитник' },
  total_amount:    5,
  min_game_amount: 1,
  max_game_amount: 5
)
football_forward = football.sports_positions.create(
  name:            { en: 'Forward', ru: 'Нападающий' },
  total_amount:    3,
  min_game_amount: 1,
  max_game_amount: 3
)

basketball.sports_positions.create(
  name:            { en: 'Center', ru: 'Центровой' },
  total_amount:    2,
  min_game_amount: 1,
  max_game_amount: 2
)
basketball.sports_positions.create(
  name:            { en: 'Power Forward', ru: 'Тяжёлый форвард' },
  total_amount:    2,
  min_game_amount: 1,
  max_game_amount: 2
)
basketball.sports_positions.create(
  name:            { en: 'Small Forward', ru: 'Лёгкий форвард' },
  total_amount:    2,
  min_game_amount: 1,
  max_game_amount: 2
)
basketball.sports_positions.create(
  name:            { en: 'Point Guard', ru: 'Разыгрывающий защитник' },
  total_amount:    2,
  min_game_amount: 1,
  max_game_amount: 2
)
basketball.sports_positions.create(
  name:            { en: 'Shooting Guard', ru: 'Атакующий защитник' },
  total_amount:    2,
  min_game_amount: 1,
  max_game_amount: 2
)

hockey.sports_positions.create(
  name:            { en: 'Goalie', ru: 'Вратарь' },
  total_amount:    2,
  min_game_amount: 1,
  max_game_amount: 2
)
hockey.sports_positions.create(
  name:            { en: 'Defenseman', ru: 'Защитник' },
  total_amount:    6,
  min_game_amount: 2,
  max_game_amount: 6
)
hockey.sports_positions.create(
  name:            { en: 'Forward', ru: 'Нападающий' },
  total_amount:    9,
  min_game_amount: 3,
  max_game_amount: 9
)

rpl2022 = rpl.leagues_seasons.create name: '2021/2022', active: true
nba2022 = nba.leagues_seasons.create name: '2021/2022', active: true
nhl2022 = nhl.leagues_seasons.create name: '2021/2022', active: true

overall_fantasy_rpl_league = rpl2022.all_fantasy_leagues.create leagueable: rpl2022, name: 'Overall'
overall_fantasy_nba_league = nba2022.all_fantasy_leagues.create leagueable: nba2022, name: 'Overall'
overall_fantasy_nhl_league = nhl2022.all_fantasy_leagues.create leagueable: nhl2022, name: 'Overall'

spartak = Team.create name: { en: 'Spartak', ru: 'Спартак' }
zenit = Team.create name: { en: 'Zenit', ru: 'Зенит' }
lokomotiv = Team.create name: { en: 'Lokomotiv', ru: 'Локомотив' }
cska = Team.create name: { en: 'CSKA', ru: 'ЦСКА' }
dinamo = Team.create name: { en: 'Dinamo', ru: 'Динамо' }
sochi = Team.create name: { en: 'Sochi', ru: 'Сочи' }
krasnodar = Team.create name: { en: 'Krasnodar', ru: 'Краснодар' }

spartak_rpl2022 = Leagues::Seasons::Team.create team: spartak, leagues_season: rpl2022
zenit_rpl2022 = Leagues::Seasons::Team.create team: zenit, leagues_season: rpl2022
lokomotiv_rpl2022 = Leagues::Seasons::Team.create team: lokomotiv, leagues_season: rpl2022
cska_rpl2022 = Leagues::Seasons::Team.create team: cska, leagues_season: rpl2022
dinamo_rpl2022 = Leagues::Seasons::Team.create team: dinamo, leagues_season: rpl2022
sochi_rpl2022 = Leagues::Seasons::Team.create team: sochi, leagues_season: rpl2022
krasnodar_rpl2022 = Leagues::Seasons::Team.create team: krasnodar, leagues_season: rpl2022

maksimenko = football_goalkeeper.players.create name: { en: 'Maksimenko Alexander', ru: 'Максименко Александр' }
guilherme = football_goalkeeper.players.create name: { en: 'Guilherme Marinato', ru: 'Гилерме Маринато' }
akinfeev = football_goalkeeper.players.create name: { en: 'Akinfeev Igor', ru: 'Акинфеев Игорь' }
shunin = football_goalkeeper.players.create name: { en: 'Shunin Anton', ru: 'Шунин Антон' }
safonov = football_goalkeeper.players.create name: { en: 'Safonov Matvey', ru: 'Сафонов Матвей' }

rakitskyi = football_defender.players.create name: { en: 'Rakitskyi Yaroslav', ru: 'Ракицкий Ярослав' }
lovren = football_defender.players.create name: { en: 'Lovren Dejan', ru: 'Ловрен Деян' }
dzhikiia = football_defender.players.create name: { en: 'Dzhikiia Georgy', ru: 'Джикия Георгий' }
fernandes = football_defender.players.create name: { en: 'Fernandes Mario', ru: 'Фернандес Марио' }
gigot = football_defender.players.create name: { en: 'Gigot Samuel', ru: 'Жиго Самуэль' }
karavaev = football_defender.players.create name: { en: 'Karavaev Vyacheslav', ru: 'Караваев Вячеслав' }
diveev = football_defender.players.create name: { en: 'Diveev Igor', ru: 'Дивеев Игорь' }

ozdoev = football_midfielder.players.create name: { en: 'Ozdoev Magomed', ru: 'Оздоев Магомед' }
zobnin = football_midfielder.players.create name: { en: 'Zobnin Roman', ru: 'Зобнин Роман' }
zhemaletdinov = football_midfielder.players.create name: { en: 'Zhemaletdinov Rifat', ru: 'Жемалетдинов Рифат' }
dzagoev = football_midfielder.players.create name: { en: 'Dzagoev Alan', ru: 'Дзагоев Алан' }
mostovoy = football_midfielder.players.create name: { en: 'Mostovoy Andrey', ru: 'Мостовой Андрей' }
barinov = football_midfielder.players.create name: { en: 'Barinov Dmitry', ru: 'Баринов Дмитрий' }
fomin = football_midfielder.players.create name: { en: 'Fomin Daniil', ru: 'Фомин Даниил' }
bakaev = football_midfielder.players.create name: { en: 'Bakaev Zelimkhan', ru: 'Бакаев Зелимхан' }
ionov = football_midfielder.players.create name: { en: 'Ionov Alexey', ru: 'Ионов Алексей' }
sutormin = football_midfielder.players.create name: { en: 'Sutormin Alexey', ru: 'Сутормин Алексей' }

azmoun = football_forward.players.create name: { en: 'Azmoun Sardar', ru: 'Азмун Сердар' }
dzyuba = football_forward.players.create name: { en: 'Dzyuba Artem', ru: 'Дзюба Артём' }
sobolev = football_forward.players.create name: { en: 'Sobolev Alexander', ru: 'Соболев Александр' }
smolov = football_forward.players.create name: { en: 'Smolov Fyodor', ru: 'Смолов Фёдор' }
zabolotnyy = football_forward.players.create name: { en: 'Zabolotnyy Anton', ru: 'Заболотный Антон' }

Teams::Player.create leagues_seasons_team: spartak_rpl2022, player: maksimenko, price_cents: 450
Teams::Player.create leagues_seasons_team: lokomotiv_rpl2022, player: guilherme, price_cents: 450
Teams::Player.create leagues_seasons_team: cska_rpl2022, player: akinfeev, price_cents: 450
Teams::Player.create leagues_seasons_team: dinamo_rpl2022, player: shunin, price_cents: 450
Teams::Player.create leagues_seasons_team: krasnodar_rpl2022, player: safonov, price_cents: 450

Teams::Player.create leagues_seasons_team: zenit_rpl2022, player: rakitskyi, price_cents: 500
Teams::Player.create leagues_seasons_team: zenit_rpl2022, player: lovren, price_cents: 500
Teams::Player.create leagues_seasons_team: zenit_rpl2022, player: karavaev, price_cents: 500
Teams::Player.create leagues_seasons_team: spartak_rpl2022, player: dzhikiia, price_cents: 500
Teams::Player.create leagues_seasons_team: cska_rpl2022, player: fernandes, price_cents: 500
Teams::Player.create leagues_seasons_team: spartak_rpl2022, player: gigot, price_cents: 500
Teams::Player.create leagues_seasons_team: cska_rpl2022, player: diveev, price_cents: 500

Teams::Player.create leagues_seasons_team: zenit_rpl2022, player: ozdoev, price_cents: 700
Teams::Player.create leagues_seasons_team: spartak_rpl2022, player: zobnin, price_cents: 700
Teams::Player.create leagues_seasons_team: lokomotiv_rpl2022, player: zhemaletdinov, price_cents: 700
Teams::Player.create leagues_seasons_team: lokomotiv_rpl2022, player: barinov, price_cents: 700
Teams::Player.create leagues_seasons_team: dinamo_rpl2022, player: fomin, price_cents: 700
Teams::Player.create leagues_seasons_team: cska_rpl2022, player: dzagoev, price_cents: 700
Teams::Player.create leagues_seasons_team: zenit_rpl2022, player: mostovoy, price_cents: 700
Teams::Player.create leagues_seasons_team: spartak_rpl2022, player: bakaev, price_cents: 700
Teams::Player.create leagues_seasons_team: krasnodar_rpl2022, player: ionov, price_cents: 700
Teams::Player.create leagues_seasons_team: zenit_rpl2022, player: sutormin, price_cents: 700

Teams::Player.create leagues_seasons_team: zenit_rpl2022, player: azmoun, price_cents: 1000
Teams::Player.create leagues_seasons_team: zenit_rpl2022, player: dzyuba, price_cents: 1000
Teams::Player.create leagues_seasons_team: spartak_rpl2022, player: sobolev, price_cents: 1000
Teams::Player.create leagues_seasons_team: lokomotiv_rpl2022, player: smolov, price_cents: 1000
Teams::Player.create leagues_seasons_team: cska_rpl2022, player: zabolotnyy, price_cents: 1000

week1 = rpl2022.weeks.create position: 1
week2 = rpl2022.weeks.create position: 2
week3 = rpl2022.weeks.create position: 3
week4 = rpl2022.weeks.create position: 4
week5 = rpl2022.weeks.create position: 5
week6 = rpl2022.weeks.create position: 6
week7 = rpl2022.weeks.create position: 7
week8 = rpl2022.weeks.create position: 8

week1_fantasy_rpl_league = rpl2022.all_fantasy_leagues.create leagueable: week1, name: 'Week 1'

Games::CreateService.call(week: week1, home_season_team: cska_rpl2022, visitor_season_team: lokomotiv_rpl2022)
Games::CreateService.call(week: week2, home_season_team: zenit_rpl2022, visitor_season_team: krasnodar_rpl2022)
Games::CreateService.call(week: week2, home_season_team: dinamo_rpl2022, visitor_season_team: cska_rpl2022)
Games::CreateService.call(week: week3, home_season_team: lokomotiv_rpl2022, visitor_season_team: zenit_rpl2022)
Games::CreateService.call(week: week4, home_season_team: lokomotiv_rpl2022, visitor_season_team: krasnodar_rpl2022)
Games::CreateService.call(week: week5, home_season_team: spartak_rpl2022, visitor_season_team: sochi_rpl2022)
Games::CreateService.call(week: week5, home_season_team: zenit_rpl2022, visitor_season_team: cska_rpl2022)
Games::CreateService.call(week: week5, home_season_team: dinamo_rpl2022, visitor_season_team: lokomotiv_rpl2022)
Games::CreateService.call(week: week6, home_season_team: sochi_rpl2022, visitor_season_team: dinamo_rpl2022)
Games::CreateService.call(week: week6, home_season_team: cska_rpl2022, visitor_season_team: spartak_rpl2022)
Games::CreateService.call(week: week7, home_season_team: krasnodar_rpl2022, visitor_season_team: sochi_rpl2022)
Games::CreateService.call(week: week8, home_season_team: cska_rpl2022, visitor_season_team: krasnodar_rpl2022)
Games::CreateService.call(week: week8, home_season_team: zenit_rpl2022, visitor_season_team: sochi_rpl2022)
