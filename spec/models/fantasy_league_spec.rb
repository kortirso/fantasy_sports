# frozen_string_literal: true

describe FantasyLeague, type: :model do
  it 'factory should be valid' do
    fantasy_league = build :fantasy_league

    expect(fantasy_league).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:leagueable) }
    it { is_expected.to have_many(:fantasy_leagues_teams).class_name('::FantasyLeagues::Team').with_foreign_key(:fantasy_league_id).dependent(:destroy) }
    it { is_expected.to have_many(:fantasy_teams).through(:fantasy_leagues_teams) }
  end
end
