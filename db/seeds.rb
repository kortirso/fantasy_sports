if Sport.count.zero?
  Sport.create name: { en: 'Football', ru: 'Футбол' }
  Sport.create name: { en: 'Basketball', ru: 'Баскетбол' }
  Sport.create name: { en: 'Hockey', ru: 'Хоккей' }
end
