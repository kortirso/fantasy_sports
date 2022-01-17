# frozen_string_literal: true

describe Games::FetchService, type: :service do
  subject(:service_call) {
    described_class
    .new(
      player_statistic_update_service: player_statistic_update_service,
      fetch_service:                   fetch_service
    )
    .call(game: game)
  }

  let(:player_statistic_update_service) { double }
  let(:fetch_service) { double }
  let(:fetch_service_result) { double }

  let!(:game) { create :game }
  let!(:teams_player1) { create :teams_player, seasons_team: game.home_season_team, active: true, shirt_number: 1 }
  let!(:teams_player2) { create :teams_player, seasons_team: game.visitor_season_team, active: true, shirt_number: 2 }
  let!(:games_player1) { create :games_player, game: game, teams_player: teams_player1 }
  let!(:games_player2) { create :games_player, game: game, teams_player: teams_player2 }

  before do
    allow(fetch_service).to receive(:call).and_return(fetch_service_result)
    allow(fetch_service_result).to receive(:result).and_return(
      [
        { 1 => { 'MP' => 90 } },
        { 2 => { 'MP' => 45 } }
      ]
    )

    allow(player_statistic_update_service).to receive(:call)
  end

  context 'for valid params' do
    it 'calls updating players statistic', :aggregate_failures do
      service_call

      expect(player_statistic_update_service).to have_received(:call).with(
        games_player: games_player1,
        statistic:    { 'MP' => 90 }
      )
      expect(player_statistic_update_service).to have_received(:call).with(
        games_player: games_player2,
        statistic:    { 'MP' => 45 }
      )
    end

    it 'and it succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end
end
