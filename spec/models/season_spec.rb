# frozen_string_literal: true

describe Season do
  it 'factory should be valid' do
    season = build :season

    expect(season).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:league) }
    it { is_expected.to have_many(:seasons_teams).class_name('Seasons::Team').dependent(:destroy) }
    it { is_expected.to have_many(:teams).through(:seasons_teams) }
    it { is_expected.to have_many(:weeks).dependent(:destroy) }
    it { is_expected.to have_many(:all_fantasy_leagues).class_name('::FantasyLeague').dependent(:destroy) }
    it { is_expected.to have_many(:fantasy_teams).through(:all_fantasy_leagues) }
    it { is_expected.to have_many(:fantasy_leagues).dependent(:destroy) }
    it { is_expected.to have_many(:players_seasons).class_name('Players::Season').dependent(:destroy) }
    it { is_expected.to have_many(:players).through(:players_seasons) }
  end
end
