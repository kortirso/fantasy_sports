# frozen_string_literal: true

describe FantasyLeague, type: :model do
  it 'factory should be valid' do
    fantasy_league = build :fantasy_league

    expect(fantasy_league).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:leagueable) }
  end
end
