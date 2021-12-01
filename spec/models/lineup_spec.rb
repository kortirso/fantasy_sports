# frozen_string_literal: true

describe Lineup, type: :model do
  it 'factory should be valid' do
    lineup = build :lineup

    expect(lineup).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:fantasy_team) }
    it { is_expected.to belong_to(:week) }
    it { is_expected.to have_many(:lineups_players).class_name('::Lineups::Player').with_foreign_key(:lineup_id).dependent(:destroy) }
    it { is_expected.to have_many(:teams_player).through(:lineups_players) }
  end
end
