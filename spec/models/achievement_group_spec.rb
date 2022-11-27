# frozen_string_literal: true

describe AchievementGroup do
  it 'factory should be valid' do
    achievement_group = build :achievement_group

    expect(achievement_group).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:parent).class_name('AchievementGroup').optional }
    it { is_expected.to have_many(:achievements).dependent(:destroy) }
    it { is_expected.to have_many(:children).class_name('AchievementGroup').dependent(:nullify) }
  end
end
