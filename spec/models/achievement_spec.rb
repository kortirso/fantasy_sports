# frozen_string_literal: true

describe Achievement do
  it 'factory should be valid' do
    achievement = build :achievement

    expect(achievement).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end
end
