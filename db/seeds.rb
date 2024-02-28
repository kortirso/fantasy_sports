Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each do |seed|
  puts "Loading seeds - #{seed}!"
  load seed
end

Season.active.each do |season|
  oracul_place = OraculPlace.create(
    placeable: season,
    name: { en: season.league.name['en'], ru: season.league.name['ru'] },
    active: true
  )
  oracul_place.oracul_leagues.create name: 'Delphi'
end

Cup.active.each do |cup|
  oracul_place = OraculPlace.create(
    placeable: cup,
    name: { en: cup.name['en'], ru: cup.name['ru'] },
    active: true
  )
  oracul_place.oracul_leagues.create name: 'Delphi'
end
