# frozen_string_literal: true

describe FantasyCups::Round do
  it 'factory should be valid' do
    fantasy_cups_round = build :fantasy_cups_round

    expect(fantasy_cups_round).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:fantasy_cup).class_name('::FantasyCup') }
    it { is_expected.to belong_to(:week).class_name('::Week') }
    it { is_expected.to have_many(:fantasy_cups_pairs).class_name('::FantasyCups::Pair').dependent(:destroy) }
  end
end
