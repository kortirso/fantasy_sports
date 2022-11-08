# frozen_string_literal: true

describe Player do
  it 'factory should be valid' do
    player = build :player

    expect(player).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_many(:teams_players).class_name('Teams::Player').dependent(:destroy) }
    it { is_expected.to have_many(:seasons_teams).through(:teams_players) }
    it { is_expected.to have_one(:active_teams_player).class_name('Teams::Player') }
    it { is_expected.to have_one(:active_seasons_team).through(:active_teams_player) }
    it { is_expected.to have_many(:players_seasons).class_name('Players::Season').dependent(:destroy) }
    it { is_expected.to have_many(:seasons).through(:players_seasons) }
  end
end
