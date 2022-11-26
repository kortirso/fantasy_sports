# frozen_string_literal: true

describe Games::StatisticsService, type: :service do
  subject(:service_call) { described_class.call(game: game) }

  context 'for valid params' do
    let(:game) { create :game }
    let!(:teams_player) { create :teams_player, seasons_team: game.home_season_team }

    before { create :games_player, statistic: { 'GS' => 3 }, game: game, teams_player: teams_player }

    it 'returns game statistics' do
      service = service_call

      expect(service.result).to eq(
        [
          { key: 'GS', home_team: [[teams_player.player.name, 3]], visitor_team: [] },
          { key: 'A', home_team: [], visitor_team: [] },
          { key: 'YC', home_team: [], visitor_team: [] },
          { key: 'RC', home_team: [], visitor_team: [] },
          { key: 'S', home_team: [], visitor_team: [] },
          { key: 'B', home_team: [], visitor_team: [] }
        ]
      )
    end

    it 'succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end
end
