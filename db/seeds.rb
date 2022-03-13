Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each do |seed|
  puts "Loading seeds - #{seed}!"
  load seed
end
