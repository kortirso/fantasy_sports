# frozen_string_literal: true

describe Lineups::Players::CreateService, type: :service do
  subject(:service_call) { described_class.call(lineup: lineup) }

  context 'for football' do
    let!(:lineup) { create :lineup }
    let!(:players) { create_list :player, 3, position_kind: Positionable::GOALKEEPER }
    let!(:teams_player1) { create :teams_player, player: players[0], active: true }
    let!(:teams_player2) { create :teams_player, player: players[1], active: true }
    let!(:teams_player3) { create :teams_player, player: players[2], active: true }

    before do
      create :fantasy_teams_player, teams_player: teams_player1, fantasy_team: lineup.fantasy_team
      create :fantasy_teams_player, teams_player: teams_player2, fantasy_team: lineup.fantasy_team
      create :fantasy_teams_player, teams_player: teams_player3, fantasy_team: lineup.fantasy_team

      allow(Sports).to receive(:positions_for_sport).and_return({
        'football_goalkeeper' => {
          'default_amount' => 1
        }
      })
    end

    it 'creates 1 active lineup player' do
      expect { service_call }.to change(lineup.lineups_players.active, :count).by(1)
    end

    it 'and creates 1 not active lineup player' do
      expect { service_call }.to change(lineup.lineups_players.inactive, :count).by(2)
    end

    it 'and it succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end
end
