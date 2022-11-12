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

    create :lineups_player, lineup: lineup, change_order: 0, points: 4
    create :lineups_player, lineup: lineup, change_order: 0, points: nil
    create :lineups_player, lineup: lineup, change_order: 1, points: 1
  end

  context 'for simple lineup' do
    it 'updates lineup points' do
      service_call

      expect(lineup.reload.points).to eq 4
    end

    it 'calls updating points for fantasy teams' do
      service_call

      expect(fantasy_teams_update_points_service).to(
        have_received(:call).with(fantasy_team_ids: [lineup.fantasy_team_id])
      )
    end

    it 'succeeds' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end

  context 'for lineup with bench boost' do
    before { lineup.update(active_chips: [Chipable::BENCH_BOOST]) }

    it 'updates lineup points with bench players' do
      service_call

      expect(lineup.reload.points).to eq 5
    end

    it 'calls updating points for fantasy teams' do
      service_call

      expect(fantasy_teams_update_points_service).to(
        have_received(:call).with(fantasy_team_ids: [lineup.fantasy_team_id])
      )
    end

    it 'succeeds' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end
end
