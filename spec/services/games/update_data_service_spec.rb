# frozen_string_literal: true

describe Games::UpdateDataService, type: :service do
  subject(:service_call) {
    described_class
    .new(
      player_statistic_update_service: player_statistic_update_service,
      form_change_service: form_change_service
    )
    .call(game: game, game_data: game_data)
  }

  let(:player_statistic_update_service) { double }
  let(:form_change_service) { double }
  let(:player_statistic_update_service_call) { double }
  let(:points_result) { 10 }

  let!(:game) { create :game, source: Sourceable::INSTAT }
  let!(:teams_player1) { create :teams_player, seasons_team: game.home_season_team, active: true, shirt_number: 1 }
  let!(:teams_player2) { create :teams_player, seasons_team: game.visitor_season_team, active: true, shirt_number: 2 }
  let!(:games_player1) { create :games_player, game: game, teams_player: teams_player1 }
  let!(:games_player2) { create :games_player, game: game, teams_player: teams_player2 }
  let(:game_data) {
    [
      { points: 0, players: { 1 => { 'MP' => 90 } } },
      { points: 0, players: { 2 => { 'MP' => 45 } } }
    ]
  }

  before do
    game.week.league.update(sport_kind: Sportable::FOOTBALL)

    allow(player_statistic_update_service).to receive(:call).and_return(player_statistic_update_service_call)
    allow(player_statistic_update_service_call).to receive(:result).and_return(points_result)
    allow(form_change_service).to receive(:call)
  end

  context 'for valid params' do
    it 'calls updating players statistic', :aggregate_failures do
      service_call

      expect(player_statistic_update_service).to have_received(:call).with(
        games_player: games_player1,
        statistic: { 'MP' => 90 }
      )
      expect(player_statistic_update_service).to have_received(:call).with(
        games_player: games_player2,
        statistic: { 'MP' => 45 }
      )
    end

    it 'calls form_change_service' do
      service_call

      expect(form_change_service).to have_received(:call).with(
        games_ids: [game.id],
        seasons_teams_ids: [game.home_season_team_id, game.visitor_season_team_id]
      )
    end

    it 'succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end
end
