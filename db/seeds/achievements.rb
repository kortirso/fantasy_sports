general_group = Kudos::AchievementGroup.create(
  name: { en: 'General', ru: 'Общая' }
)
basketball_group = Kudos::AchievementGroup.create(
  name: { en: 'Basketball', ru: 'Баскетбол' }
)
football_group = Kudos::AchievementGroup.create(
  name: { en: 'Football', ru: 'Футбол' }
)

Kudos::Achievement.create(
  award_name: 'fantasy_team_create',
  points: 5,
  title: { 'en' => 'Beginning', 'ru' => 'Начало' },
  description: {
    'en' => 'Create fantasy team for any sport',
    'ru' => 'Создайте фэнтези команду для любого вида спорта'
  },
  kudos_achievement_group: general_group
)

Kudos::Achievement.create(
  award_name: 'basketball_lineup_points',
  rank: 1,
  points: 5,
  title: { 'en' => 'First points', 'ru' => 'Первые очки' },
  description: {
    'en' => 'Earn at least 100 points by fantasy team in a week',
    'ru' => 'Получите как минимум 100 очков командой за неделю'
  },
  kudos_achievement_group: basketball_group
)
Kudos::Achievement.create(
  award_name: 'basketball_lineup_points',
  rank: 2,
  points: 10,
  title: { 'en' => 'First results', 'ru' => 'Первые результаты' },
  description: {
    'en' => 'Earn at least 250 points by fantasy team in a week',
    'ru' => 'Получите как минимум 250 очков командой за неделю'
  },
  kudos_achievement_group: basketball_group
)
Kudos::Achievement.create(
  award_name: 'basketball_lineup_points',
  rank: 3,
  points: 25,
  title: { 'en' => 'Good progress', 'ru' => 'Хороший прогресс' },
  description: {
    'en' => 'Earn at least 500 points by fantasy team in a week',
    'ru' => 'Получите как минимум 500 очков командой за неделю'
  },
  kudos_achievement_group: basketball_group
)
Kudos::Achievement.create(
  award_name: 'basketball_lineup_points',
  rank: 4,
  points: 50,
  title: { 'en' => 'You know what to do', 'ru' => 'Вы знаете, что делать' },
  description: {
    'en' => 'Earn at least 750 points by fantasy team in a week',
    'ru' => 'Получите как минимум 750 очков командой за неделю'
  },
  kudos_achievement_group: basketball_group
)
Kudos::Achievement.create(
  award_name: 'basketball_lineup_points',
  rank: 5,
  points: 100,
  title: { 'en' => 'Coach of the week', 'ru' => 'Тренер недели' },
  description: {
    'en' => 'Earn at least 1000 points by fantasy team in a week',
    'ru' => 'Получите как минимум 1000 очков командой за неделю'
  },
  kudos_achievement_group: basketball_group
)

Kudos::Achievement.create(
  award_name: 'basketball_top_lineup',
  rank: 1,
  points: 5,
  title: { 'en' => 'First top team', 'ru' => 'Первая топ-команда' },
  description: {
    'en' => 'Reach team top-1000 in a week league',
    'ru' => 'Достигните командой топ-1000 за неделю'
  },
  kudos_achievement_group: basketball_group
)
Kudos::Achievement.create(
  award_name: 'basketball_top_lineup',
  rank: 2,
  points: 10,
  title: { 'en' => 'Real Top', 'ru' => 'Топчик' },
  description: {
    'en' => 'Reach team top-100 in a week league',
    'ru' => 'Достигните командой топ-100 за неделю'
  },
  kudos_achievement_group: basketball_group
)
Kudos::Achievement.create(
  award_name: 'basketball_top_lineup',
  rank: 3,
  points: 50,
  title: { 'en' => 'Amazing Team', 'ru' => 'Удивительная команда' },
  description: {
    'en' => 'Reach team top-10 in a week league',
    'ru' => 'Достигните командой топ-10 за неделю'
  },
  kudos_achievement_group: basketball_group
)
Kudos::Achievement.create(
  award_name: 'basketball_top_lineup',
  rank: 4,
  points: 100,
  title: { 'en' => 'Dream Team', 'ru' => 'Команда мечты' },
  description: {
    'en' => 'Reach team top-1 in a week league',
    'ru' => 'Достигните командой топ-1 за неделю'
  },
  kudos_achievement_group: basketball_group
)

Kudos::Achievement.create(
  award_name: 'no_one_team_players',
  points: 25,
  title: { 'en' => 'Diversity', 'ru' => 'Разнообразие' },
  description: {
    'en' => 'Lineup does not have 2 players from one team',
    'ru' => 'В составе все игроки из разных команд'
  },
  kudos_achievement_group: general_group
)

Kudos::Achievement.create(
  award_name: 'team_of_friends',
  points: 25,
  title: { 'en' => 'Team of friends', 'ru' => 'Команда друзей' },
  description: {
    'en' => 'Lineup contains players from minimum available teams',
    'ru' => 'Состав состоит из игроков минимального количества команд'
  },
  kudos_achievement_group: general_group
)

Kudos::Achievement.create(
  award_name: 'team_of_twins',
  points: 50,
  title: { 'en' => 'Team of Twins', 'ru' => 'Команда близнецов' },
  description: {
    'en' => 'Lineup players have the same shirt numbers',
    'ru' => 'Весь состав имеет одинаковые номера'
  },
  kudos_achievement_group: general_group
)

Kudos::Achievement.create(
  award_name: 'straight_players',
  points: 50,
  title: { 'en' => 'Straight', 'ru' => 'Стрит' },
  description: {
    'en' => 'Lineup players shirt numbers differ by 1',
    'ru' => 'Номера игроков состава различаются на 1'
  },
  kudos_achievement_group: general_group
)

Kudos::Achievement.create(
  award_name: 'football_lineup_points',
  rank: 1,
  points: 5,
  title: { 'en' => 'First points', 'ru' => 'Первые очки' },
  description: {
    'en' => 'Earn at least 10 points by fantasy team in a week',
    'ru' => 'Получите как минимум 10 очков командой за неделю'
  },
  kudos_achievement_group: football_group
)
Kudos::Achievement.create(
  award_name: 'football_lineup_points',
  rank: 2,
  points: 10,
  title: { 'en' => 'First results', 'ru' => 'Первые результаты' },
  description: {
    'en' => 'Earn at least 25 points by fantasy team in a week',
    'ru' => 'Получите как минимум 25 очков командой за неделю'
  },
  kudos_achievement_group: football_group
)
Kudos::Achievement.create(
  award_name: 'football_lineup_points',
  rank: 3,
  points: 25,
  title: { 'en' => 'Good progress', 'ru' => 'Хороший прогресс' },
  description: {
    'en' => 'Earn at least 50 points by fantasy team in a week',
    'ru' => 'Получите как минимум 50 очков командой за неделю'
  },
  kudos_achievement_group: football_group
)
Kudos::Achievement.create(
  award_name: 'football_lineup_points',
  rank: 4,
  points: 50,
  title: { 'en' => 'You know what to do', 'ru' => 'Вы знаете, что делать' },
  description: {
    'en' => 'Earn at least 75 points by fantasy team in a week',
    'ru' => 'Получите как минимум 75 очков командой за неделю'
  },
  kudos_achievement_group: football_group
)
Kudos::Achievement.create(
  award_name: 'football_lineup_points',
  rank: 5,
  points: 100,
  title: { 'en' => 'Coach of the week', 'ru' => 'Тренер недели' },
  description: {
    'en' => 'Earn at least 100 points by fantasy team in a week',
    'ru' => 'Получите как минимум 100 очков командой за неделю'
  },
  kudos_achievement_group: football_group
)
