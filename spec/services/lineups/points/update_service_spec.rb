# frozen_string_literal: true

describe Lineups::Points::UpdateService, type: :service do
  subject(:service_call) {
    described_class
      .new(fantasy_teams_update_points_service: fantasy_teams_update_points_service)
      .call(lineup_ids: lineup_ids, final_points: final_points)
  }

  let(:fantasy_teams_update_points_service) { double }
  let!(:lineup) { create :lineup }
  let(:lineup_ids) { [lineup.id] }
  let(:final_points) { false }

  before do
    allow(fantasy_teams_update_points_service).to receive(:call)

    create :lineups_player, lineup: lineup, change_order: 0, points: 4
    create :lineups_player, lineup: lineup, change_order: 0, points: nil
    create :lineups_player, lineup: lineup, change_order: 1, points: 1
  end

  context 'for simple lineup' do
    it 'updates points', :aggregate_failures do
      expect(service_call.success?).to be_truthy
      expect(lineup.reload.points).to eq 4
      expect(lineup.final_points).to be_falsy
      expect(fantasy_teams_update_points_service).to(
        have_received(:call).with(fantasy_team_ids: [lineup.fantasy_team_id])
      )
    end

    context 'for final points' do
      let(:final_points) { true }

      it 'updates points', :aggregate_failures do
        expect(service_call.success?).to be_truthy
        expect(lineup.reload.points).to eq 4
        expect(lineup.final_points).to be_truthy
        expect(fantasy_teams_update_points_service).to(
          have_received(:call).with(fantasy_team_ids: [lineup.fantasy_team_id])
        )
      end
    end
  end

  context 'for lineup with bench boost' do
    before { lineup.update(active_chips: [Chipable::BENCH_BOOST]) }

    it 'updates lineup points with bench players', :aggregate_failures do
      expect(service_call.success?).to be_truthy
      expect(lineup.reload.points).to eq 5
      expect(fantasy_teams_update_points_service).to(
        have_received(:call).with(fantasy_team_ids: [lineup.fantasy_team_id])
      )
    end
  end
end
