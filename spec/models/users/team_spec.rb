# frozen_string_literal: true

describe Users::Team, type: :model do
  it 'factory should be valid' do
    users_team = build :users_team

    expect(users_team).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end
end
