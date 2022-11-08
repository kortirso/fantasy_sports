# frozen_string_literal: true

describe Lineups::Player do
  it 'factory should be valid' do
    lineups_player = build :lineups_player

    expect(lineups_player).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:lineup).class_name('::Lineup') }
    it { is_expected.to belong_to(:teams_player).class_name('::Teams::Player') }
  end
end
