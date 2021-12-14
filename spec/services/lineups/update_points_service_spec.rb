# frozen_string_literal: true

describe Lineups::UpdatePointsService, type: :service do
  subject(:service_call) {
    described_class.call(lineup_ids: lineup_ids)
  }

  let!(:lineup) { create :lineup }
  let(:lineup_ids) { [lineup.id] }

  before do
    create :lineups_player, lineup: lineup, active: true, points: 4
    create :lineups_player, lineup: lineup, active: true, points: nil
    create :lineups_player, lineup: lineup, active: false, points: 1
  end

  it 'updates lineup points' do
    service_call

    expect(lineup.reload.points).to eq 4
  end

  it 'and it succeed' do
    service = service_call

    expect(service.success?).to be_truthy
  end
end
