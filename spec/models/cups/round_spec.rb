# frozen_string_literal: true

describe Cups::Round do
  it 'factory should be valid' do
    cups_round = build :cups_round

    expect(cups_round).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:cup).class_name('::Cup') }
    it { is_expected.to belong_to(:week).class_name('::Week') }
    it { is_expected.to have_many(:cups_pairs).class_name('::Cups::Pair').dependent(:destroy) }
  end
end
