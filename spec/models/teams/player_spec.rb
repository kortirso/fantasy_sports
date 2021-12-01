# frozen_string_literal: true

describe Teams::Player, type: :model do
  it 'factory should be valid' do
    teams_player = build :teams_player

    expect(teams_player).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:seasons_team).class_name('::Seasons::Team') }
    it { is_expected.to belong_to(:player).class_name('::Player') }
    it { is_expected.to have_many(:games_players).class_name('::Games::Player').with_foreign_key(:teams_player_id).dependent(:destroy) }
    it { is_expected.to have_many(:games).through(:games_players) }
    it { is_expected.to have_many(:fantasy_teams_players).class_name('FantasyTeams::Player').with_foreign_key(:teams_player_id).dependent(:destroy) }
    it { is_expected.to have_many(:fantasy_teams).through(:fantasy_teams_players) }
    it { is_expected.to have_many(:lineups_players).class_name('::Lineups::Player').with_foreign_key(:teams_player_id).dependent(:destroy) }
    it { is_expected.to have_many(:lineups).through(:lineups_players) }
  end
end
