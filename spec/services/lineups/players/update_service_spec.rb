# frozen_string_literal: true

describe Lineups::Players::UpdateService, type: :service do
  subject(:service_call) {
    described_class.new(
      update_football_players_service: update_football_players_service
    ).call(lineup: lineup, lineups_players_params: lineups_players_params)
  }

  let!(:lineup) { create :lineup }
  let(:update_football_players_service) { double }
  let(:call_result) { double }
  let(:lineups_players_params) { { id: 1, active: true, change_order: 0 } }

  before do
    allow(update_football_players_service).to receive(:call).and_return(call_result)
    allow(call_result).to receive(:errors).and_return(['Error'])
  end

  context 'for football' do
    context 'for invalid data' do
      before do
        allow(call_result).to receive(:failure?).and_return(true)
      end

      it 'calls football_service' do
        service_call

        expect(update_football_players_service).to have_received(:call)
      end

      it 'and it fails' do
        service = service_call

        expect(service.failure?).to be_truthy
      end
    end

    context 'for valid data' do
      before do
        allow(call_result).to receive(:failure?).and_return(false)
      end

      it 'calls football_service' do
        service_call

        expect(update_football_players_service).to have_received(:call)
      end

      it 'and it succeed' do
        service = service_call

        expect(service.success?).to be_truthy
      end
    end
  end
end
