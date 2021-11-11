if Sport.count.zero?
  football = Sport.create name: { en: 'Football', ru: 'Футбол' }
  basketball = Sport.create name: { en: 'Basketball', ru: 'Баскетбол' }
  hockey = Sport.create name: { en: 'Hockey', ru: 'Хоккей' }
end

if League.count.zero?
  rpl = football.leagues.create name: { en: 'Russian Premier Liga', ru: 'Российская Премьер-Лига' }
  nba = basketball.leagues.create name: { en: 'NBA', ru: 'НБА' }
  nhl = hockey.leagues.create name: { en: 'NHL', ru: 'НХЛ' }
end

if Sports::Position.count.zero?
  football.sports_positions.create(
    name:            { en: 'Goalkeeper', ru: 'Вратарь' },
    total_amount:    2,
    min_game_amount: 1,
    max_game_amount: 1
  )
  football.sports_positions.create(
    name:            { en: 'Defender', ru: 'Защитник' },
    total_amount:    5,
    min_game_amount: 3,
    max_game_amount: 5
  )
  football.sports_positions.create(
    name:            { en: 'Midfielder', ru: 'Полузащитник' },
    total_amount:    5,
    min_game_amount: 1,
    max_game_amount: 5
  )
  football.sports_positions.create(
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
end

if Leagues::Season.count.zero?
  rpl2022 = rpl.leagues_seasons.create name: '2021/2022', active: true
  nba2022 = nba.leagues_seasons.create name: '2021/2022', active: true
  nhl2022 = nhl.leagues_seasons.create name: '2021/2022', active: true
end

if Team.count.zero?
  spartak = Team.create name: { en: 'Spartak', ru: 'Спартак' }
  zenit = Team.create name: { en: 'Zenit', ru: 'Зенит' }
  lokomotiv = Team.create name: { en: 'Lokomotiv', ru: 'Локомотив' }
  cska = Team.create name: { en: 'CSKA', ru: 'ЦСКА' }
  dinamo = Team.create name: { en: 'Dinamo', ru: 'Динамо' }
  sochi = Team.create name: { en: 'Sochi', ru: 'Сочи' }
  krasnodar = Team.create name: { en: 'Krasnodar', ru: 'Краснодар' }
end

if Leagues::Seasons::Team.count.zero?
  Leagues::Seasons::Team.create team: spartak, leagues_season: rpl2022
  Leagues::Seasons::Team.create team: zenit, leagues_season: rpl2022
  Leagues::Seasons::Team.create team: lokomotiv, leagues_season: rpl2022
  Leagues::Seasons::Team.create team: cska, leagues_season: rpl2022
  Leagues::Seasons::Team.create team: dinamo, leagues_season: rpl2022
  Leagues::Seasons::Team.create team: sochi, leagues_season: rpl2022
  Leagues::Seasons::Team.create team: krasnodar, leagues_season: rpl2022
end
