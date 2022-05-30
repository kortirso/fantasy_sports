# frozen_string_literal: true

describe Lineups::Players::Points::UpdateService, type: :service do
  subject(:service_call) {
    described_class.new(
      lineups_update_points_service: lineups_update_points_service
    ).call(teams_players_points: teams_players_points, week_id: week.id)
  }

  let!(:week) { create :week }
  let!(:teams_player) { create :teams_player }
  let!(:lineup1) { create :lineup, week: week }
  let!(:lineup2) { create :lineup, week: week }
  let!(:lineups_player1) { create :lineups_player, lineup: lineup1, teams_player: teams_player, points: 0 }
  let!(:lineups_player2) { create :lineups_player, lineup: lineup2, teams_player: teams_player, points: 1 }
  let(:teams_players_points) { { teams_player.id => 10 } }
  let(:lineups_update_points_service) { double }

  before do
    allow(lineups_update_points_service).to receive(:call)
  end

  it 'updates lineups players points', :aggregate_failures do
    service_call

    expect(lineups_player1.reload.points).to eq 10
    expect(lineups_player2.reload.points).to eq 10
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
