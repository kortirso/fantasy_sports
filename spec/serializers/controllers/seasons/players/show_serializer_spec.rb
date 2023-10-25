# frozen_string_literal: true

RSpec.describe Controllers::Seasons::Players::ShowSerializer do
  subject(:serializer) { described_class.new(teams_player).serializable_hash }

  let!(:teams_player) { create :teams_player }

  it 'serializer contains empty attributes', :aggregate_failures do
    expect(serializer.dig(:data, :attributes, :teams_selected_by)).to eq 0
    expect(serializer.dig(:data, :attributes, :points_per_game)).to eq 0
  end

  context 'with played games' do
    before do
      create :games_player, teams_player: teams_player, statistic: {}
      create :games_player, teams_player: teams_player, statistic: { 'MP' => 1 }
      create :games_player, teams_player: teams_player, statistic: { 'MP' => 2 }

      teams_player.player.update!(points: 28.4)
    end

    it 'serializer contains attributes' do
      expect(serializer.dig(:data, :attributes, :points_per_game)).to eq 14.2
    end
  end
end
