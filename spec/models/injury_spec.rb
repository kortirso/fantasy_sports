# frozen_string_literal: true

describe Injury do
  it 'factory should be valid' do
    injury = build :injury

    expect(injury).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:players_season) }
  end
end
