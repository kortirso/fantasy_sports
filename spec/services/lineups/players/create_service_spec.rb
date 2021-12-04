# frozen_string_literal: true

describe Lineups::Players::CreateService, type: :service do
  subject(:service_call) {
    described_class.new(
      create_football_players_service: create_football_players_service
    ).call(lineup: lineup)
  }

  let!(:lineup) { create :lineup }
  let(:create_football_players_service) { double }

  before do
    allow(create_football_players_service).to receive(:call)
  end

  context 'for football' do
    it 'calls football_service' do
      service_call

      expect(create_football_players_service).to have_received(:call)
    end

    it 'and it succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end
end
