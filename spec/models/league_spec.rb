# frozen_string_literal: true

describe League, type: :model do
  it 'factory should be valid' do
    league = build :league

    expect(league).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:sport) }
    it { is_expected.to have_many(:seasons).dependent(:destroy) }
  end
end
