# frozen_string_literal: true

describe Team, type: :model do
  it 'factory should be valid' do
    team = build :team

    expect(team).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_many(:leagues_seasons_teams).class_name('Leagues::Seasons::Team').dependent(:destroy) }
    it { is_expected.to have_many(:leagues_seasons).through(:leagues_seasons_teams) }
    it { is_expected.to have_many(:teams_players).class_name('Teams::Player').dependent(:destroy) }
    it { is_expected.to have_many(:players).through(:teams_players) }
    it { is_expected.to have_many(:active_teams_players).class_name('Teams::Player') }
    it { is_expected.to have_many(:active_players).through(:active_teams_players) }
  end
end
