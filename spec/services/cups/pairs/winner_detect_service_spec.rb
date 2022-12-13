# frozen_string_literal: true

describe Cups::Pairs::WinnerDetectService, type: :service do
  subject(:service_call) { described_class.call(cups_pair: cups_pair) }

  let!(:lineup1) { create :lineup, points: 2 }
  let!(:lineup2) { create :lineup, points: 1 }
  let!(:cups_pair) { create :cups_pair, home_lineup: lineup1, visitor_lineup: lineup2 }
  let(:service_object) { double }

  before do
    allow(Cups::Pairs::WinnerDetect::ForFootballService).to receive(:call).and_return(service_object)
    allow(service_object).to receive(:result).and_return(lineup1.fantasy_team)
  end

  context 'when home lineup has more points' do
    it 'returns home fantasy team as winner and succeed', :aggregate_failures do
      service = service_call

      expect(service.result).to eq lineup1.fantasy_team
      expect(service.success?).to be_truthy
    end
  end

  context 'when visitor lineup has more points' do
    before { lineup2.update(points: 3) }

    it 'returns visitor fantasy team as winner and succeed', :aggregate_failures do
      service = service_call

      expect(service.result).to eq lineup2.fantasy_team
      expect(service.success?).to be_truthy
    end
  end

  context 'when lineups have equal points' do
    before { lineup2.update(points: 2) }

    it 'calls winner detect for service' do
      service_call

      expect(Cups::Pairs::WinnerDetect::ForFootballService).to have_received(:call)
    end

    it 'returns visitor fantasy team as winner and succeed', :aggregate_failures do
      service = service_call

      expect(service.result).to eq lineup1.fantasy_team
      expect(service.success?).to be_truthy
    end
  end
end
