# frozen_string_literal: true

describe Team, type: :model do
  it 'factory should be valid' do
    team = build :team

    expect(team).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_many(:leagues_seasons_teams).class_name('Leagues::Seasons::Team').dependent(:destroy) }
    it { is_expected.to have_many(:leagues_seasons).through(:leagues_seasons_teams) }
  end
end
