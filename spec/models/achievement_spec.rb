# frozen_string_literal: true

describe Achievement do
  it 'factory should be valid' do
    achievement = build :achievement

    expect(achievement).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:achievement_group) }
    it { is_expected.to have_many(:users_achievements).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:users_achievements) }
  end
end
