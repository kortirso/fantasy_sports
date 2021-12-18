# frozen_string_literal: true

describe Players::Statistic::UpdateService, type: :service do
  subject(:service_call) { described_class.call(season_id: season.id, player_ids: [player.id]) }

  let!(:season) { create :season }
  let!(:week1) { create :week, season: season }
  let!(:week2) { create :week, season: season }
  let!(:game1) { create :game, week: week1 }
  let!(:game2) { create :game, week: week2 }
  let!(:player) { create :player }
  let!(:teams_player) { create :teams_player, player: player }
  let!(:games_player1) {
    create :games_player, teams_player: teams_player, game: game1, points: 2, statistic: { 'MP' => 60 }
  }
  let!(:games_player2) {
    create :games_player, teams_player: teams_player, game: game2, points: 5, statistic: { 'MP' => 90, 'GS' => 1 }
  }

  it 'updates player statistic', :aggregate_failures do
    service_call

    expect(player.reload.points).to eq(games_player1.points + games_player2.points)
    expect(player.reload.statistic).to eq({ 'MP' => 150, 'GS' => 1 })
  end

  it 'and it succeed' do
    service = service_call

    expect(service.success?).to be_truthy
  end
end
