# frozen_string_literal: true

describe Users::Team, type: :model do
  it 'factory should be valid' do
    users_team = build :users_team

    expect(users_team).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:fantasy_leagues_teams).class_name('::FantasyLeagues::Team').with_foreign_key(:users_team_id).dependent(:destroy) }
    it { is_expected.to have_many(:fantasy_leagues).through(:fantasy_leagues_teams) }
  end
end
