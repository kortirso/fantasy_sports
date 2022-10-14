# frozen_string_literal: true

describe Lineups::Players::CopyService, type: :service do
  subject(:service_call) { described_class.call(lineup: lineup, previous_lineup: previous_lineup) }

  context 'for football' do
    let!(:lineup) { create :lineup }
    let!(:previous_lineup) { create :lineup }
    let!(:lineups_player1) { create :lineups_player, lineup: previous_lineup, status: Lineups::Player::ASSISTANT }
    let!(:lineups_player2) { create :lineups_player, lineup: previous_lineup, status: Lineups::Player::CAPTAIN }
    let!(:lineups_player3) { create :lineups_player, lineup: previous_lineup, status: Lineups::Player::REGULAR }

    it 'creates 3 lineup players' do
      expect { service_call }.to change(lineup.lineups_players, :count).by(3)
    end

    it 'sets params of previous lineup players', :aggregate_failures do
      service_call

      expect(lineup.lineups_players.captain.first.teams_player_id).to eq lineups_player2.teams_player_id
      expect(lineup.lineups_players.assistant.first.teams_player_id).to eq lineups_player1.teams_player_id
      expect(lineup.lineups_players.regular.first.teams_player_id).to eq lineups_player3.teams_player_id
    end

    it 'succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end
end
