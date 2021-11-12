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

ozdoev = football_midfielder.players.create name: { en: 'Ozdoev Magomed', ru: 'Оздоев Магомед' }
zobnin = football_midfielder.players.create name: { en: 'Zobnin Roman', ru: 'Зобнин Роман' }
zhemaletdinov = football_midfielder.players.create name: { en: 'Zhemaletdinov Rifat', ru: 'Жемалетдинов Рифат' }
dzagoev = football_midfielder.players.create name: { en: 'Dzagoev Alan', ru: 'Дзагоев Алан' }
mostovoy = football_midfielder.players.create name: { en: 'Mostovoy Andrey', ru: 'Мостовой Андрей' }

azmoun = football_forward.players.create name: { en: 'Azmoun Sardar', ru: 'Азмун Сердар' }
dzyuba = football_forward.players.create name: { en: 'Dzyuba Artem', ru: 'Дзюба Артём' }
sobolev = football_forward.players.create name: { en: 'Sobolev Alexander', ru: 'Соболев Александр' }
smolov = football_forward.players.create name: { en: 'Smolov Fyodor', ru: 'Смолов Фёдор' }
zabolotnyy = football_forward.players.create name: { en: 'Zabolotnyy Anton', ru: 'Заболотный Антон' }

Teams::Player.create leagues_seasons_team: spartak_rpl2022, player: maksimenko
Teams::Player.create leagues_seasons_team: lokomotiv_rpl2022, player: guilherme
Teams::Player.create leagues_seasons_team: cska_rpl2022, player: akinfeev
Teams::Player.create leagues_seasons_team: dinamo_rpl2022, player: shunin
Teams::Player.create leagues_seasons_team: krasnodar_rpl2022, player: safonov
Teams::Player.create leagues_seasons_team: zenit_rpl2022, player: rakitskyi
Teams::Player.create leagues_seasons_team: zenit_rpl2022, player: lovren
Teams::Player.create leagues_seasons_team: spartak_rpl2022, player: dzhikiia
Teams::Player.create leagues_seasons_team: cska_rpl2022, player: fernandes
Teams::Player.create leagues_seasons_team: spartak_rpl2022, player: gigot
Teams::Player.create leagues_seasons_team: zenit_rpl2022, player: ozdoev
Teams::Player.create leagues_seasons_team: spartak_rpl2022, player: zobnin
Teams::Player.create leagues_seasons_team: lokomotiv_rpl2022, player: zhemaletdinov
Teams::Player.create leagues_seasons_team: cska_rpl2022, player: dzagoev
Teams::Player.create leagues_seasons_team: zenit_rpl2022, player: mostovoy
Teams::Player.create leagues_seasons_team: zenit_rpl2022, player: azmoun
Teams::Player.create leagues_seasons_team: zenit_rpl2022, player: dzyuba
Teams::Player.create leagues_seasons_team: spartak_rpl2022, player: sobolev
Teams::Player.create leagues_seasons_team: lokomotiv_rpl2022, player: smolov
Teams::Player.create leagues_seasons_team: cska_rpl2022, player: zabolotnyy
