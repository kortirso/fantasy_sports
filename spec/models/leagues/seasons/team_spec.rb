# frozen_string_literal: true

describe Leagues::Seasons::Team, type: :model do
  it 'factory should be valid' do
    leagues_seasons_team = build :leagues_seasons_team

    expect(leagues_seasons_team).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:leagues_season).class_name('Leagues::Season') }
    it { is_expected.to belong_to(:team).class_name('::Team') }
  end
end
