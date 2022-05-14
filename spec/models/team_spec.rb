# frozen_string_literal: true

describe Team, type: :model do
  it 'factory should be valid' do
    team = build :team

    expect(team).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_many(:seasons_teams).class_name('Seasons::Team').dependent(:destroy) }
    it { is_expected.to have_many(:seasons).through(:seasons_teams) }
    it { is_expected.to have_many(:fantasy_leagues).dependent(:destroy) }
  end
end
