require 'csv'

league = League.create(
  sport_kind: 'football',
  name: { en: 'Champions League', ru: 'Лига чемпионов' },
  points_system: { W: 3, D: 1, L: 0 }
)

group_stage2024 = league.cups.create(
  name: { en: 'Champions League 2023/2024', ru: 'Лига чемпионов 2023/2024' }
  active: false
)

playoffs2024 = league.cups.create(
  name: { en: 'Playoff Champions League 2023/2024', ru: 'Плейофф Лиги чемпионов 2023/2024' }
  active: true
)

round1 = playoffs2024.cups_rounds.create name: '1/8', position: 1, status: Cups::Round::ACTIVE
round2 = playoffs2024.cups_rounds.create name: '1/4', position: 2, status: Cups::Round::COMING
round3 = playoffs2024.cups_rounds.create name: '1/2', position: 3, status: Cups::Round::COMING
round4 = playoffs2024.cups_rounds.create name: 'Final', position: 4, status: Cups::Round::COMING
