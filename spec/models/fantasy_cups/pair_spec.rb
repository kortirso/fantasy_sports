# frozen_string_literal: true

describe FantasyCups::Pair do
  it 'factory should be valid' do
    fantasy_cups_pair = build :fantasy_cups_pair

    expect(fantasy_cups_pair).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:fantasy_cups_round).class_name('::FantasyCups::Round') }
    it { is_expected.to belong_to(:home_lineup).class_name('::Lineup').optional }
    it { is_expected.to belong_to(:visitor_lineup).class_name('::Lineup').optional }
  end
end
