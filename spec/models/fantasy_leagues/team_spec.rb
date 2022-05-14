# frozen_string_literal: true

describe FantasyLeagues::Team, type: :model do
  it 'factory should be valid' do
    fantasy_leagues_team = build :fantasy_leagues_team

    expect(fantasy_leagues_team).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:fantasy_league).class_name('::FantasyLeague') }
    it { is_expected.to belong_to(:pointable) }
  end
end
