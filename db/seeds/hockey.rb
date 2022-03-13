nhl = League.create(sport_kind: 'hockey', name: { en: 'NHL', ru: 'НХЛ' })

nhl2022 = nhl.seasons.create name: '2021/2022', active: true

overall_fantasy_nhl_league = nhl2022.all_fantasy_leagues.create leagueable: nhl2022, name: 'Overall'
