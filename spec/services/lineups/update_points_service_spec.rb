# frozen_string_literal: true

describe Lineups::UpdatePointsService, type: :service do
  subject(:service_call) {
    described_class
      .new(fantasy_teams_update_points_service: fantasy_teams_update_points_service)
      .call(lineup_ids: lineup_ids)
  }

  let(:fantasy_teams_update_points_service) { double }
  let!(:lineup) { create :lineup }
  let(:lineup_ids) { [lineup.id] }

  before do
    allow(fantasy_teams_update_points_service).to receive(:call)

    create :lineups_player, lineup: lineup, active: true, points: 4
    create :lineups_player, lineup: lineup, active: true, points: nil
    create :lineups_player, lineup: lineup, active: false, points: 1
  end

  it 'updates lineup points' do
    service_call

    expect(lineup.reload.points).to eq 4
  end

  it 'and calls updating points for fantasy teams' do
    service_call

    expect(fantasy_teams_update_points_service).to have_received(:call).with(fantasy_team_ids: [lineup.fantasy_team_id])
  end

  it 'and it succeed' do
    service = service_call

    expect(service.success?).to be_truthy
  end
end
