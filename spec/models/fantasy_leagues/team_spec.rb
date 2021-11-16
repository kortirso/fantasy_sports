# frozen_string_literal: true

describe FantasyLeagues::Team, type: :model do
  it 'factory should be valid' do
    fantasy_leagues_team = build :fantasy_leagues_team

    expect(fantasy_leagues_team).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:fantasy_league).class_name('::FantasyLeague').with_foreign_key(:fantasy_league_id) }
    it { is_expected.to belong_to(:fantasy_team).class_name('::FantasyTeam').with_foreign_key(:fantasy_team_id) }
  end
end
