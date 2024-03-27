# frozen_string_literal: true

describe Like do
  it 'factory should be valid' do
    like = build :like

    expect(like).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:likeable) }
  end
end
