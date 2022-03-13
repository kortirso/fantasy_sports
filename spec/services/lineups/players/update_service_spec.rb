# frozen_string_literal: true

describe Lineups::Players::UpdateService, type: :service do
  subject(:service_call) {
    described_class.new(
      players_validator_service: players_validator_service
    ).call(lineup: lineup, lineups_players_params: lineups_players_params)
  }

  let!(:lineup) { create :lineup }
  let(:players_validator_service) { double }
  let(:players_validator) { double }
  let(:call_result) { double }
  let(:validator_result) { ['Error'] }
  let(:lineups_players_params) { [{ id: 1, active: true, change_order: 0 }] }

  before do
    allow(players_validator_service).to receive(:new).and_return(players_validator)
    allow(players_validator).to receive(:call).and_return(validator_result)
  end

  context 'for football' do
    context 'for invalid data' do
      it 'calls football_service' do
        service_call

        expect(players_validator).to have_received(:call)
      end

      it 'and it fails' do
        service = service_call

        expect(service.failure?).to be_truthy
      end
    end

    context 'for valid data' do
      let(:validator_result) { [] }

      it 'calls football_service' do
        service_call

        expect(players_validator).to have_received(:call)
      end

      it 'and it succeed' do
        service = service_call

        expect(service.success?).to be_truthy
      end
    end
  end
end
