# frozen_string_literal: true

describe League do
  it 'factory should be valid' do
    league = build :league

    expect(league).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_many(:seasons).dependent(:destroy) }
  end
end
