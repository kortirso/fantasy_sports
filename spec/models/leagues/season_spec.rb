# frozen_string_literal: true

describe Leagues::Season, type: :model do
  it 'factory should be valid' do
    leagues_season = build :leagues_season

    expect(leagues_season).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:league) }
    it { is_expected.to have_many(:leagues_seasons_teams).class_name('Leagues::Seasons::Team').dependent(:destroy) }
    it { is_expected.to have_many(:teams).through(:leagues_seasons_teams) }
    it { is_expected.to have_many(:weeks).dependent(:destroy) }
    it { is_expected.to have_many(:all_fantasy_leagues).class_name('::FantasyLeague').with_foreign_key(:leagues_season_id).dependent(:destroy) }
    it { is_expected.to have_many(:users_teams).through(:all_fantasy_leagues) }
    it { is_expected.to have_many(:fantasy_leagues).dependent(:destroy) }
  end
end
