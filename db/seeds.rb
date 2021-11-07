if Sport.count.zero?
  football = Sport.create name: { en: 'Football', ru: 'Футбол' }
  basketball = Sport.create name: { en: 'Basketball', ru: 'Баскетбол' }
  hockey = Sport.create name: { en: 'Hockey', ru: 'Хоккей' }
end

if League.count.zero?
  football.leagues.create name: { en: 'Russian Premier Liga', ru: 'Российская Премьер-Лига' }
  basketball.leagues.create name: { en: 'NBA', ru: 'НБА' }
  hockey.leagues.create name: { en: 'NHL', ru: 'НХЛ' }
end
