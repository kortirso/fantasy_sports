# frozen_string_literal: true

describe Leagues::Seasons::Team, type: :model do
  it 'factory should be valid' do
    leagues_seasons_team = build :leagues_seasons_team

    expect(leagues_seasons_team).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:leagues_season).class_name('Leagues::Season') }
    it { is_expected.to belong_to(:team).class_name('::Team') }
    it { is_expected.to have_many(:teams_players).class_name('Teams::Player').dependent(:destroy) }
    it { is_expected.to have_many(:players).through(:teams_players) }
    it { is_expected.to have_many(:active_teams_players).class_name('Teams::Player') }
    it { is_expected.to have_many(:active_players).through(:active_teams_players) }
  end
end
