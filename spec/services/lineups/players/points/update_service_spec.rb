# frozen_string_literal: true

describe Lineups::Players::Points::UpdateService, type: :service do
  subject(:service_call) {
    described_class.new(
      lineups_update_points_service: lineups_update_points_service
    ).call(team_player_ids: team_player_ids, week_id: week.id)
  }

  let!(:week) { create :week }
  let!(:teams_player1) { create :teams_player }
  let!(:teams_player2) { create :teams_player }
  let!(:lineup1) { create :lineup, week: week }
  let!(:lineup2) { create :lineup, week: week }
  let!(:lineups_player1) { create :lineups_player, lineup: lineup1, teams_player: teams_player1, points: 0 }
  let!(:lineups_player2) {
    create :lineups_player, lineup: lineup2, teams_player: teams_player1, points: 0, status: Lineups::Player::CAPTAIN
  }
  let!(:lineups_player3) { create :lineups_player, lineup: lineup1, teams_player: teams_player2, points: 0 }
  let(:team_player_ids) { [teams_player1.id, teams_player2.id] }
  let(:lineups_update_points_service) { double }
  let!(:game1) { create :game, week: week }
  let!(:game2) { create :game, week: week }

  before do
    allow(lineups_update_points_service).to receive(:call)

    create :games_player, game: game1, teams_player: teams_player1, points: 4
    create :games_player, game: game1, teams_player: teams_player2, points: 7
    create :games_player, game: game2, teams_player: teams_player2, points: 13
  end

  context 'for simple lineup' do
    it 'updates lineups players points', :aggregate_failures do
      expect(service_call.success?).to be_truthy
      expect(lineups_update_points_service).to have_received(:call).with(
        lineup_ids: [lineup1.id, lineup2.id],
        final_points: false
      )
      expect(lineups_player1.reload.points).to eq 4
      expect(lineups_player2.reload.points).to eq 8
      expect(lineups_player3.reload.points).to eq 20
    end
  end

  context 'for lineup with triple captain chip' do
    before { lineup2.update(active_chips: [Chipable::TRIPLE_CAPTAIN]) }

    it 'updates lineups players points', :aggregate_failures do
      expect(service_call.success?).to be_truthy
      expect(lineups_player1.reload.points).to eq 4
      expect(lineups_player2.reload.points).to eq 12
      expect(lineups_player3.reload.points).to eq 20
      expect(lineups_update_points_service).to have_received(:call).with(
        lineup_ids: [lineup1.id, lineup2.id],
        final_points: false
      )
    end
  end
end
