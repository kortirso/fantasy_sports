# frozen_string_literal: true

RSpec.describe Controllers::Seasons::Players::ShowSerializer do
  subject(:serializer) { described_class.new(players_season).serializable_hash }

  let!(:players_season) { create :players_season, average_points: 14.2 }
  let!(:teams_player) { create :teams_player, players_season: players_season }

  it 'serializer contains empty attributes', :aggregate_failures do
    expect(serializer.dig(:data, :attributes, :teams_selected_by)).to eq 0
    expect(serializer.dig(:data, :attributes, :average_points)).to eq 14.2
  end

  context 'with played games' do
    before do
      create :games_player, teams_player: teams_player, statistic: {}
      create :games_player, teams_player: teams_player, statistic: { 'MP' => 1 }
      create :games_player, teams_player: teams_player, statistic: { 'MP' => 2 }
    end

    it 'serializer contains attributes' do
      expect(serializer.dig(:data, :attributes, :average_points)).to eq 14.2
    end
  end
end
