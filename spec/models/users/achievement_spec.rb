# frozen_string_literal: true

describe Users::Achievement do
  it 'factory should be valid' do
    users_achievement = build :users_achievement

    expect(users_achievement).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:achievement) }
  end
end
