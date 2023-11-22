# frozen_string_literal: true

describe Games::UpdateService, type: :service do
  subject(:service_call) { described_class.call(game: game, game_data: game_data) }

  let(:points_calculate_service) { double }
  let(:points_result) { 10 }

  let!(:game) { create :game, source: Sourceable::INSTAT }
  let!(:teams_player1) {
    create :teams_player, seasons_team: game.home_season_team, active: true, shirt_number_string: '1'
  }
  let!(:teams_player2) {
    create :teams_player, seasons_team: game.visitor_season_team, active: true, shirt_number_string: '2'
  }
  let(:game_data) {
    [
      { points: 1, players: { '1' => { 'MP' => 90 } } },
      { points: 2, players: { '2' => { 'MP' => 45 } } }
    ]
  }

  before do
    create :injury, players_season: teams_player1.players_season, return_at: nil
    game.week.league.update(sport_kind: Sportable::FOOTBALL)

    create :games_player, game: game, teams_player: teams_player1
    create :games_player, game: game, teams_player: teams_player2

    allow(Games::Players::Points::Calculate::FootballService).to receive(:new).and_return(points_calculate_service)
    allow(points_calculate_service).to receive_messages(call: points_calculate_service, result: points_result)
  end

  context 'for valid params' do
    it 'calls updating players statistic', :aggregate_failures do
      expect { service_call }.to change(Injury, :count).by(-1)
      expect(service_call.success?).to be_truthy
      expect(points_calculate_service).to have_received(:call).twice
      expect(game.reload.points).to eq([1, 2])
    end
  end
end
