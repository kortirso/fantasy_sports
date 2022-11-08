# frozen_string_literal: true

describe FantasyTeam do
  it 'factory should be valid' do
    fantasy_team = build :fantasy_team

    expect(fantasy_team).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:fantasy_leagues_teams).class_name('FantasyLeagues::Team').dependent(:destroy) }
    it { is_expected.to have_many(:fantasy_leagues).through(:fantasy_leagues_teams) }
    it { is_expected.to have_many(:fantasy_teams_players).class_name('FantasyTeams::Player').dependent(:destroy) }
    it { is_expected.to have_many(:teams_players).through(:fantasy_teams_players) }
  end
end
