# frozen_string_literal: true

describe Cups::Pair do
  it 'factory should be valid' do
    cups_pair = build :cups_pair

    expect(cups_pair).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:cups_round).class_name('::Cups::Round') }
    it { is_expected.to have_many(:oraculs_forecasts).class_name('::Oraculs::Forecast').dependent(:destroy) }
  end
end
