# frozen_string_literal: true

describe FantasyTeam, type: :model do
  it 'factory should be valid' do
    fantasy_team = build :fantasy_team

    expect(fantasy_team).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:fantasy_leagues_teams).class_name('FantasyLeagues::Team').with_foreign_key(:fantasy_team_id).dependent(:destroy) }
    it { is_expected.to have_many(:fantasy_leagues).through(:fantasy_leagues_teams) }
    it { is_expected.to have_many(:fantasy_teams_players).class_name('FantasyTeams::Player').with_foreign_key(:fantasy_team_id).dependent(:destroy) }
    it { is_expected.to have_many(:teams_players).through(:fantasy_teams_players) }
  end
end
