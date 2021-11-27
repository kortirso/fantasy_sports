# frozen_string_literal: true

describe FantasyTeams::Lineups::Player, type: :model do
  it 'factory should be valid' do
    fantasy_teams_lineups_player = build :fantasy_teams_lineups_player

    expect(fantasy_teams_lineups_player).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:fantasy_teams_lineup).class_name('::FantasyTeams::Lineup').with_foreign_key(:fantasy_teams_lineup_id) }
    it { is_expected.to belong_to(:teams_player).class_name('::Teams::Player').with_foreign_key(:teams_player_id) }
  end
end
