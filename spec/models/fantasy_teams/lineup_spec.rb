# frozen_string_literal: true

describe FantasyTeams::Lineup, type: :model do
  it 'factory should be valid' do
    fantasy_teams_lineup = build :fantasy_teams_lineup

    expect(fantasy_teams_lineup).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:fantasy_team).class_name('::FantasyTeam') }
    it { is_expected.to belong_to(:week).class_name('::Week') }
    it { is_expected.to have_many(:fantasy_teams_lineups_players).class_name('::FantasyTeams::Lineups::Player').with_foreign_key(:fantasy_teams_lineup_id).dependent(:destroy) }
    it { is_expected.to have_many(:teams_player).through(:fantasy_teams_lineups_players) }
  end
end
