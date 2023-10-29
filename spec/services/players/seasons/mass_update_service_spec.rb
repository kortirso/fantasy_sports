# frozen_string_literal: true

describe Players::Seasons::MassUpdateService, type: :service do
  subject(:service_call) { described_class.new.call(season_id: season.id, player_ids: [player.id]) }

  let!(:season) { create :season }
  let!(:player) { create :player }
  let!(:players_season) { create :players_season, season: season, player: player }

  before do
    week1 = create :week, season: season, position: 5, status: 'active'
    week2 = create :week, season: season, position: 1, status: 'finished'
    teams_player = create :teams_player, player: player, players_season: players_season
    game1 = create :game, week: week2
    create :games_player, game: game1, teams_player: teams_player, points: 23, statistic: { 'MP' => 1 }
    game2 = create :game, week: week1
    create :games_player, game: game2, teams_player: teams_player, points: 14, statistic: { 'MP' => 3 }
    game3 = create :game, week: week1
    create :games_player, game: game3, teams_player: teams_player, points: 0, statistic: { 'MP' => 0 }
  end

  it 'updates players seasons', :aggregate_failures do
    service_call

    expect(players_season.reload.points).to eq 37
    expect(players_season.average_points).to eq 18.5
    expect(players_season.form).to eq 7
    expect(players_season.statistic).to eq({ 'MP' => 4 })
  end
end
