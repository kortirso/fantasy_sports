# frozen_string_literal: true

describe Players::Season do
  it 'factory should be valid' do
    players_season = build :players_season

    expect(players_season).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:season).class_name('::Season') }
    it { is_expected.to belong_to(:player).class_name('::Player') }
    it { is_expected.to have_many(:fantasy_teams_watches).class_name('FantasyTeams::Watch').dependent(:destroy) }
  end
end
