# frozen_string_literal: true

describe Cups::Pairs::ScoreDetectService, type: :service do
  subject(:service_call) { described_class.call(cups_pair: cups_pair, fantasy_team: fantasy_team) }

  let!(:lineup1) { create :lineup, points: 2 }
  let!(:lineup2) { create :lineup, points: 1 }
  let!(:cups_pair) { create :cups_pair, home_lineup: lineup1, visitor_lineup: lineup2 }

  context 'when fantasy team is home team' do
    let(:fantasy_team) { lineup1.fantasy_team }

    it 'returns score and succeed', :aggregate_failures do
      service = service_call

      expect(service.result).to eq [2, 1]
      expect(service.success?).to be_truthy
    end
  end

  context 'when fantasy team is visitor team' do
    let(:fantasy_team) { lineup2.fantasy_team }

    it 'returns reverse score and succeed', :aggregate_failures do
      service = service_call

      expect(service.result).to eq [1, 2]
      expect(service.success?).to be_truthy
    end
  end
end
