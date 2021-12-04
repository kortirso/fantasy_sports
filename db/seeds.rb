rpl = League.create(sport_kind: 'football', name: { en: 'Russian Premier Liga', ru: 'Российская Премьер-Лига' })
nba = League.create(sport_kind: 'basketball', name: { en: 'NBA', ru: 'НБА' })
nhl = League.create(sport_kind: 'hockey', name: { en: 'NHL', ru: 'НХЛ' })

rpl2022 = rpl.seasons.create name: '2021/2022', active: true
nba2022 = nba.seasons.create name: '2021/2022', active: true
nhl2022 = nhl.seasons.create name: '2021/2022', active: true

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

spartak_rpl2022 = Seasons::Team.create team: spartak, season: rpl2022
zenit_rpl2022 = Seasons::Team.create team: zenit, season: rpl2022
lokomotiv_rpl2022 = Seasons::Team.create team: lokomotiv, season: rpl2022
cska_rpl2022 = Seasons::Team.create team: cska, season: rpl2022
dinamo_rpl2022 = Seasons::Team.create team: dinamo, season: rpl2022
sochi_rpl2022 = Seasons::Team.create team: sochi, season: rpl2022
krasnodar_rpl2022 = Seasons::Team.create team: krasnodar, season: rpl2022

maksimenko = Player.create position_kind: 'football_goalkeeper', name: { en: 'Maksimenko Alexander', ru: 'Максименко Александр' }
guilherme = Player.create position_kind: 'football_goalkeeper', name: { en: 'Guilherme Marinato', ru: 'Гилерме Маринато' }
akinfeev = Player.create position_kind: 'football_goalkeeper', name: { en: 'Akinfeev Igor', ru: 'Акинфеев Игорь' }
shunin = Player.create position_kind: 'football_goalkeeper', name: { en: 'Shunin Anton', ru: 'Шунин Антон' }
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

Teams::Player.create seasons_team: spartak_rpl2022, player: maksimenko, price_cents: 450
Teams::Player.create seasons_team: lokomotiv_rpl2022, player: guilherme, price_cents: 450
Teams::Player.create seasons_team: cska_rpl2022, player: akinfeev, price_cents: 450
Teams::Player.create seasons_team: dinamo_rpl2022, player: shunin, price_cents: 450
Teams::Player.create seasons_team: krasnodar_rpl2022, player: safonov, price_cents: 450

Teams::Player.create seasons_team: zenit_rpl2022, player: rakitskyi, price_cents: 500
Teams::Player.create seasons_team: zenit_rpl2022, player: lovren, price_cents: 500
Teams::Player.create seasons_team: zenit_rpl2022, player: karavaev, price_cents: 500
Teams::Player.create seasons_team: spartak_rpl2022, player: dzhikiia, price_cents: 500
Teams::Player.create seasons_team: cska_rpl2022, player: fernandes, price_cents: 500
Teams::Player.create seasons_team: spartak_rpl2022, player: gigot, price_cents: 500
Teams::Player.create seasons_team: cska_rpl2022, player: diveev, price_cents: 500

Teams::Player.create seasons_team: zenit_rpl2022, player: ozdoev, price_cents: 700
Teams::Player.create seasons_team: spartak_rpl2022, player: zobnin, price_cents: 700
Teams::Player.create seasons_team: lokomotiv_rpl2022, player: zhemaletdinov, price_cents: 700
Teams::Player.create seasons_team: lokomotiv_rpl2022, player: barinov, price_cents: 700
Teams::Player.create seasons_team: dinamo_rpl2022, player: fomin, price_cents: 700
Teams::Player.create seasons_team: cska_rpl2022, player: dzagoev, price_cents: 700
Teams::Player.create seasons_team: zenit_rpl2022, player: mostovoy, price_cents: 700
Teams::Player.create seasons_team: spartak_rpl2022, player: bakaev, price_cents: 700
Teams::Player.create seasons_team: krasnodar_rpl2022, player: ionov, price_cents: 700
Teams::Player.create seasons_team: zenit_rpl2022, player: sutormin, price_cents: 700

Teams::Player.create seasons_team: zenit_rpl2022, player: azmoun, price_cents: 1000
Teams::Player.create seasons_team: zenit_rpl2022, player: dzyuba, price_cents: 1000
Teams::Player.create seasons_team: spartak_rpl2022, player: sobolev, price_cents: 1000
Teams::Player.create seasons_team: lokomotiv_rpl2022, player: smolov, price_cents: 1000
Teams::Player.create seasons_team: cska_rpl2022, player: zabolotnyy, price_cents: 1000

week1 = rpl2022.weeks.create position: 1, status: 'coming'
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
