# frozen_string_literal: true

describe FantasyTeams::Watch do
  it 'factory should be valid' do
    fantasy_teams_watch = build :fantasy_teams_watch

    expect(fantasy_teams_watch).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:fantasy_team).class_name('::FantasyTeam') }
    it { is_expected.to belong_to(:players_season).class_name('::Players::Season') }
  end
end
