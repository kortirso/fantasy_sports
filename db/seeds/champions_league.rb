require 'csv'

league = League.create(
  sport_kind: 'football',
  name: { en: 'Champions League', ru: 'Лига чемпионов' },
  points_system: { W: 3, D: 1, L: 0 },
  background_url: 'leagues/champions_league.webp'
)

group_stage2024 = league.cups.create(
  name: { en: 'Champions League 2023/2024', ru: 'Лига чемпионов 2023/2024' },
  active: false
)

playoffs2024 = league.cups.create(
  name: { en: 'Playoff Champions League 2023/2024', ru: 'Плейофф Лиги чемпионов 2023/2024' },
  active: true
)

round1 = playoffs2024.cups_rounds.create name: '1/8', position: 1, status: Cups::Round::ACTIVE
round2 = playoffs2024.cups_rounds.create name: '1/4', position: 2, status: Cups::Round::COMING
round3 = playoffs2024.cups_rounds.create name: '1/2', position: 3, status: Cups::Round::COMING
round4 = playoffs2024.cups_rounds.create name: 'Final', position: 4, status: Cups::Round::COMING

round1.cups_pairs.create(
  home_name: { en: 'Copenhagen', ru: 'Копенгаген' },
  visitor_name: { en: 'Manchester City', ru: 'Манчестер Сити' },
  start_at: DateTime.new(2024, 2, 13, 20, 0, 0),
  points: [1, 3]
)

round1.cups_pairs.create(
  home_name: { en: 'Leipzig', ru: 'РБ Лейпциг' },
  visitor_name: { en: 'Real Madrid', ru: 'Реал Мадрид' },
  start_at: DateTime.new(2024, 2, 13, 20, 0, 0),
  points: [0, 1]
)

round1.cups_pairs.create(
  home_name: { en: 'PSG', ru: 'ПСЖ' },
  visitor_name: { en: 'Real Sociedad', ru: 'Реал Сосьедад' },
  start_at: DateTime.new(2024, 2, 14, 20, 0, 0),
  points: [2, 0]
)

round1.cups_pairs.create(
  home_name: { en: 'Lazio', ru: 'Лацио' },
  visitor_name: { en: 'Bayern', ru: 'Бавария' },
  start_at: DateTime.new(2024, 2, 14, 20, 0, 0),
  points: [1, 0]
)

round1.cups_pairs.create(
  home_name: { en: 'Inter', ru: 'Интер' },
  visitor_name: { en: 'Atletico', ru: 'Атлетико' },
  start_at: DateTime.new(2024, 2, 20, 20, 0, 0),
  points: [1, 0]
)

round1.cups_pairs.create(
  home_name: { en: 'PSV', ru: 'ПСВ' },
  visitor_name: { en: 'Borussia D', ru: 'Боруссия Д' },
  start_at: DateTime.new(2024, 2, 20, 20, 0, 0),
  points: [1, 1]
)

round1.cups_pairs.create(
  home_name: { en: 'Porto', ru: 'Порту' },
  visitor_name: { en: 'Arsenal', ru: 'Арсенал' },
  start_at: DateTime.new(2024, 2, 21, 20, 0, 0),
  points: [1, 0]
)

round1.cups_pairs.create(
  home_name: { en: 'Napoli', ru: 'Наполи' },
  visitor_name: { en: 'Barcelona', ru: 'Барселона' },
  start_at: DateTime.new(2024, 2, 21, 20, 0, 0),
  points: [1, 1]
)

round1.cups_pairs.create(
  home_name: { en: 'Real Sociedad', ru: 'Реал Сосьедад' },
  visitor_name: { en: 'PSG', ru: 'ПСЖ' },
  start_at: DateTime.new(2024, 3, 5, 20, 0, 0)
)

round1.cups_pairs.create(
  home_name: { en: 'Bayern', ru: 'Бавария' },
  visitor_name: { en: 'Lazio', ru: 'Лацио' },
  start_at: DateTime.new(2024, 3, 5, 20, 0, 0)
)

round1.cups_pairs.create(
  home_name: { en: 'Manchester City', ru: 'Манчестер Сити' },
  visitor_name: { en: 'Copenhagen', ru: 'Копенгаген' },
  start_at: DateTime.new(2024, 3, 6, 20, 0, 0)
)

round1.cups_pairs.create(
  home_name: { en: 'Real Madrid', ru: 'Реал Мадрид' },
  visitor_name: { en: 'Leipzig', ru: 'РБ Лейпциг' },
  start_at: DateTime.new(2024, 3, 6, 20, 0, 0)
)

round1.cups_pairs.create(
  home_name: { en: 'Arsenal', ru: 'Арсенал' },
  visitor_name: { en: 'Porto', ru: 'Порту' },
  start_at: DateTime.new(2024, 3, 12, 20, 0, 0)
)

round1.cups_pairs.create(
  home_name: { en: 'Barcelona', ru: 'Барселона' },
  visitor_name: { en: 'Napoli', ru: 'Наполи' },
  start_at: DateTime.new(2024, 3, 12, 20, 0, 0)
)

round1.cups_pairs.create(
  home_name: { en: 'Atletico', ru: 'Атлетико' },
  visitor_name: { en: 'Inter', ru: 'Интер' },
  start_at: DateTime.new(2024, 3, 13, 20, 0, 0)
)

round1.cups_pairs.create(
  home_name: { en: 'Borussia D', ru: 'Боруссия Д' },
  visitor_name: { en: 'PSV', ru: 'ПСВ' },
  start_at: DateTime.new(2024, 3, 13, 20, 0, 0)
)

round2.cups_pairs.create
round2.cups_pairs.create
round2.cups_pairs.create
round2.cups_pairs.create
round2.cups_pairs.create
round2.cups_pairs.create
round2.cups_pairs.create
round2.cups_pairs.create

round3.cups_pairs.create
round3.cups_pairs.create
round3.cups_pairs.create
round3.cups_pairs.create

round4.cups_pairs.create
