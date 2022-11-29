# frozen_string_literal: true

describe Games::Player do
  it 'factory should be valid' do
    games_player = build :games_player

    expect(games_player).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:game) }
    it { is_expected.to belong_to(:teams_player).class_name('::Teams::Player') }
    it { is_expected.to belong_to(:seasons_team).class_name('::Seasons::Team') }
  end
end
