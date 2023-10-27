# frozen_string_literal: true

describe Games::UpdateOperation, type: :service do
  subject(:service_call) {
    described_class
    .new(
      form_change_service: form_change_service
    )
    .call(game: game, game_data: game_data)
  }

  let(:points_calculate_service) { double }
  let(:form_change_service) { double }
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
    game.week.league.update(sport_kind: Sportable::FOOTBALL)

    create :games_player, game: game, teams_player: teams_player1
    create :games_player, game: game, teams_player: teams_player2

    allow(Games::Players::Points::Calculate::FootballService).to receive(:new).and_return(points_calculate_service)
    allow(points_calculate_service).to receive_messages(call: points_calculate_service, result: points_result)
    allow(form_change_service).to receive(:call)
  end

  context 'for valid params' do
    it 'calls updating players statistic', :aggregate_failures do
      service_call

      expect(points_calculate_service).to have_received(:call).twice
      expect(form_change_service).to have_received(:call).with(
        games_ids: [game.id],
        seasons_teams_ids: [game.home_season_team_id, game.visitor_season_team_id]
      )
      expect(game.reload.points).to eq([1, 2])
      expect(service_call.success?).to be_truthy
    end
  end
end
