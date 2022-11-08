# frozen_string_literal: true

describe FantasyTeams::Player do
  it 'factory should be valid' do
    fantasy_teams_player = build :fantasy_teams_player

    expect(fantasy_teams_player).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:fantasy_team).class_name('::FantasyTeam') }
    it { is_expected.to belong_to(:teams_player).class_name('::Teams::Player') }
  end
end
