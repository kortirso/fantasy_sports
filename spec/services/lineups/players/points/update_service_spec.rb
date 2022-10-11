# frozen_string_literal: true

describe Lineups::Players::Points::UpdateService, type: :service do
  subject(:service_call) {
    described_class.new(
      lineups_update_points_service: lineups_update_points_service
    ).call(team_player_ids: team_player_ids, week_id: week.id)
  }

  let!(:week) { create :week }
  let!(:teams_player1) { create :teams_player }
  let!(:teams_player2) { create :teams_player }
  let!(:lineup1) { create :lineup, week: week }
  let!(:lineup2) { create :lineup, week: week }
  let!(:lineups_player1) { create :lineups_player, lineup: lineup1, teams_player: teams_player1, points: 0 }
  let!(:lineups_player2) { create :lineups_player, lineup: lineup2, teams_player: teams_player1, points: 0 }
  let!(:lineups_player3) { create :lineups_player, lineup: lineup1, teams_player: teams_player2, points: 0 }
  let(:team_player_ids) { [teams_player1.id, teams_player2.id] }
  let(:lineups_update_points_service) { double }
  let!(:game1) { create :game, week: week }
  let!(:game2) { create :game, week: week }

  before do
    allow(lineups_update_points_service).to receive(:call)

    create :games_player, game: game1, teams_player: teams_player1, points: 4
    create :games_player, game: game1, teams_player: teams_player2, points: 7
    create :games_player, game: game2, teams_player: teams_player2, points: 13
  end

  it 'updates lineups players points', :aggregate_failures do
    service_call

    expect(lineups_player1.reload.points).to eq 4
    expect(lineups_player2.reload.points).to eq 4
    expect(lineups_player3.reload.points).to eq 20
  end

  it 'calls lineups_update_points_service' do
    service_call

    expect(lineups_update_points_service).to have_received(:call).with(
      lineup_ids: [lineup1.id, lineup2.id]
    )
  end

  it 'succeed' do
    service = service_call

    expect(service.success?).to be_truthy
  end
end
