# frozen_string_literal: true

describe Sport, type: :model do
  it 'factory should be valid' do
    sport = build :sport

    expect(sport).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_many(:leagues).dependent(:destroy) }
    it { is_expected.to have_many(:sports_positions).class_name('Sports::Position').dependent(:destroy) }
  end
end
