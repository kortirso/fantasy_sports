general_group = AchievementGroup.create(
  name: { en: 'General', ru: 'Общая' }
)

Achievement.create(
  award_name: 'fantasy_team_create',
  points: 5,
  title: { 'en' => 'Beginning', 'ru' => 'Начало' },
  description: {
    'en' => 'Create fantasy team for any sport',
    'ru' => 'Создайте фэнтези команду для любого вида спорта'
  },
  achievement_group: general_group
)
Achievement.create(
  award_name: 'lineup_points',
  rank: 1,
  points: 10,
  title: {},
  description: {},
  achievement_group: general_group
)
Achievement.create(
  award_name: 'lineup_points',
  rank: 2,
  points: 25,
  title: {},
  description: {},
  achievement_group: general_group
)
Achievement.create(
  award_name: 'lineup_points',
  rank: 3,
  points: 50,
  title: {},
  description: {},
  achievement_group: general_group
)
