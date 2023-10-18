# frozen_string_literal: true

describe Lineup do
  it 'factory should be valid' do
    lineup = build :lineup

    expect(lineup).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:fantasy_team) }
    it { is_expected.to belong_to(:week) }
    it { is_expected.to have_many(:lineups_players).class_name('::Lineups::Player').dependent(:destroy) }
    it { is_expected.to have_many(:teams_players).through(:lineups_players) }
    it { is_expected.to have_many(:fantasy_leagues_teams).class_name('FantasyLeagues::Team').dependent(:destroy) }
    it { is_expected.to have_many(:fantasy_leagues).through(:fantasy_leagues_teams) }
    it { is_expected.to have_many(:transfers).dependent(:destroy) }
  end
end
