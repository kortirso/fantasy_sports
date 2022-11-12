# frozen_string_literal: true

describe Lineups::PlayersValidator, type: :service do
  subject(:validator_call) {
    described_class.new(sport_kind: sport_kind).call(lineup: lineup, lineups_players_params: lineups_players_params)
  }

  let(:sport_settings) {
    {
      'max_active_players' => 2,
      'changes' => true,
      'captain' => true
    }
  }
  let!(:lineup) { create :lineup }
  let!(:lineups_player1) { create :lineups_player, lineup: lineup }
  let!(:lineups_player2) { create :lineups_player, lineup: lineup }
  let!(:lineups_player3) { create :lineups_player, lineup: lineup }
  let!(:lineups_player4) { create :lineups_player, lineup: lineup }
  let!(:lineups_player5) { create :lineups_player, lineup: lineup }
  let!(:lineups_player6) { create :lineups_player, lineup: lineup }
  let!(:lineups_player7) { create :lineups_player }
  let(:lineups_players_params) {
    [
      lineups_player_params1,
      lineups_player_params2,
      lineups_player_params3,
      lineups_player_params4,
      lineups_player_params5,
      lineups_player_params6
    ]
  }
  let(:lineups_player_params1) { { uuid: lineups_player1.uuid, status: 'captain', change_order: 0 } }
  let(:lineups_player_params2) { { uuid: lineups_player2.uuid, status: 'assistant', change_order: 0 } }
  let(:lineups_player_params3) { { uuid: lineups_player3.uuid, status: 'regular', change_order: 1 } }
  let(:lineups_player_params4) { { uuid: lineups_player4.uuid, status: 'regular', change_order: 2 } }
  let(:lineups_player_params5) { { uuid: lineups_player5.uuid, status: 'regular', change_order: 3 } }
  let(:lineups_player_params6) { { uuid: lineups_player6.uuid, status: 'regular', change_order: 4 } }

  before do
    allow(Sports).to receive(:sport).and_return(sport_settings)
  end

  context 'for football' do
    let(:sport_kind) { 'football' }

    context 'when lineup_player_ids are not valid' do
      let(:lineups_player_params6) {
        { uuid: lineups_player7.uuid, status: 'regular', change_order: 4 }
      }

      it 'result contains error' do
        expect(validator_call.first).to eq('Invalid players list')
      end
    end

    context 'when amount of active players are not valid' do
      let(:lineups_player_params6) { { uuid: lineups_player6.uuid, status: 'regular', change_order: 0 } }

      it 'result contains error' do
        expect(validator_call.first).to eq('Invalid amount of active players')
      end
    end

    context 'when change order is not valid' do
      let(:lineups_player_params6) {
        { uuid: lineups_player6.uuid, status: 'regular', change_order: 5 }
      }

      it 'result contains error' do
        expect(validator_call.first).to eq('Invalid changing order')
      end
    end

    context 'when captains count is not valid' do
      let(:lineups_player_params6) { { uuid: lineups_player6.uuid, status: 'captain', change_order: 4 } }

      it 'result contains error' do
        expect(validator_call.first).to eq('Invalid captains count')
      end
    end

    context 'for valid params' do
      it 'result does not contain errors' do
        expect(validator_call.size.zero?).to be_truthy
      end
    end
  end
end
