# frozen_string_literal: true

describe Lineups::Players::UpdateService, type: :service do
  subject(:service_call) {
    described_class.new(
      players_validator_service: players_validator_service
    ).call(lineup: lineup, lineups_players_params: lineups_players_params)
  }

  let!(:lineup) { create :lineup }
  let!(:lineups_player) { create :lineups_player, lineup: lineup, active: false, change_order: 1 }
  let(:players_validator_service) { double }
  let(:players_validator) { double }
  let(:call_result) { double }
  let(:lineups_players_params) { [{ id: lineups_player.id, active: true, change_order: '0', status: 'captain' }] }

  before do
    allow(players_validator_service).to receive(:new).and_return(players_validator)
    allow(players_validator).to receive(:call).and_return(validator_result)
  end

  context 'for football' do
    context 'for invalid data' do
      let(:validator_result) { ['Error'] }

      it 'calls players_validator_service' do
        service_call

        expect(players_validator).to have_received(:call)
      end

      it 'fails' do
        service = service_call

        expect(service.failure?).to be_truthy
      end
    end

    context 'for valid data' do
      let(:validator_result) { [] }

      it 'calls players_validator_service' do
        service_call

        expect(players_validator).to have_received(:call)
      end

      it 'updates lineups player', :aggregate_failures do
        service_call

        expect(lineups_player.reload.status).to eq Lineups::Player::CAPTAIN
        expect(lineups_player.active).to be true
        expect(lineups_player.change_order).to eq 0
      end

      it 'succeed' do
        service = service_call

        expect(service.success?).to be_truthy
      end
    end
  end
end
