# frozen_string_literal: true

describe FantasyCups::Pairs::WinnerDetect::ForFootballService, type: :service do
  subject(:service_call) { described_class.call(home_lineup: home_lineup, visitor_lineup: visitor_lineup) }

  let!(:home_lineup) { create :lineup, points: 2 }
  let!(:visitor_lineup) { create :lineup, points: 1 }
  let!(:visitor_lineup_player) { create :lineups_player, lineup: visitor_lineup, statistic: { 'GS' => 0, 'GC' => 1 } }

  before do
    create :lineups_player, lineup: home_lineup, statistic: { 'GS' => 1, 'GC' => 1 }
  end

  context 'when compare higher order' do
    it 'returns home fantasy team as winner and succeed', :aggregate_failures do
      expect(service_call.result).to eq home_lineup.fantasy_team
      expect(service_call.success?).to be_truthy
    end
  end

  context 'when compare lower order' do
    before { visitor_lineup_player.update(statistic: { 'GS' => 1, 'GC' => 0 }) }

    it 'returns visitor fantasy team as winner and succeed', :aggregate_failures do
      expect(service_call.result).to eq visitor_lineup.fantasy_team
      expect(service_call.success?).to be_truthy
    end
  end
end
