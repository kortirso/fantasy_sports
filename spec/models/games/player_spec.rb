# frozen_string_literal: true

describe Games::Player, type: :model do
  it 'factory should be valid' do
    games_player = build :games_player

    expect(games_player).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:game) }
    it { is_expected.to belong_to(:player).class_name('::Player') }
  end
end
