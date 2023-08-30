# frozen_string_literal: true

describe Games::UpdateOperation, type: :service do
  subject(:service_call) {
    described_class
    .new(
      points_calculate_service: points_calculate_service,
      form_change_service: form_change_service
    )
    .call(game: game, game_data: game_data)
  }

  let(:points_calculate_service) { double }
  let(:form_change_service) { double }
  let(:points_calculate_service_call) { double }
  let(:points_result) { 10 }

  let!(:game) { create :game, source: Sourceable::INSTAT }
  let!(:teams_player1) { create :teams_player, seasons_team: game.home_season_team, active: true, shirt_number: 1 }
  let!(:teams_player2) { create :teams_player, seasons_team: game.visitor_season_team, active: true, shirt_number: 2 }
  let(:game_data) {
    [
      { points: 0, players: { 1 => { 'MP' => 90 } } },
      { points: 0, players: { 2 => { 'MP' => 45 } } }
    ]
  }

  before do
    game.week.league.update(sport_kind: Sportable::FOOTBALL)

    create :games_player, game: game, teams_player: teams_player1
    create :games_player, game: game, teams_player: teams_player2

    allow(points_calculate_service).to receive(:call).and_return(points_calculate_service_call)
    allow(points_calculate_service_call).to receive(:result).and_return(points_result)
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
      expect(service_call.success?).to be_truthy
    end
  end
end
