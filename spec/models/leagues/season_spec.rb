# frozen_string_literal: true

describe Leagues::Season, type: :model do
  it 'factory should be valid' do
    leagues_season = build :leagues_season

    expect(leagues_season).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:league) }
  end
end
