# frozen_string_literal: true

describe FantasyTeams::Lineups::Players::CreateForSportService, type: :service do
  subject(:service_call) {
    described_class.new(
      football_service: football_service
    ).call(lineup: lineup)
  }

  let!(:lineup) { create :fantasy_teams_lineup }
  let(:football_service) { double }

  before do
    allow(football_service).to receive(:call)
  end

  context 'for football' do
    before do
      lineup.week.leagues_season.league.sport.update(kind: Sport::FOOTBALL)
    end

    it 'calls football_service' do
      service_call

      expect(football_service).to have_received(:call)
    end

    it 'and it succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end
end
