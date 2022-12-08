# frozen_string_literal: true

describe Cups::Pair do
  it 'factory should be valid' do
    cups_pair = build :cups_pair

    expect(cups_pair).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:cups_round).class_name('::Cups::Round') }
    it { is_expected.to belong_to(:home_lineup).class_name('::Lineup') }
    it { is_expected.to belong_to(:visitor_lineup).class_name('::Lineup') }
  end
end
