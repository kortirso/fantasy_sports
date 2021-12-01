# frozen_string_literal: true

describe Lineups::Player, type: :model do
  it 'factory should be valid' do
    lineups_player = build :lineups_player

    expect(lineups_player).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:lineup).class_name('::Lineup').with_foreign_key(:lineup_id) }
    it { is_expected.to belong_to(:teams_player).class_name('::Teams::Player').with_foreign_key(:teams_player_id) }
  end
end
