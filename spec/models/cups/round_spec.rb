# frozen_string_literal: true

describe Cups::Round do
  it 'factory should be valid' do
    cups_round = build :cups_round

    expect(cups_round).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:cup) }
    it { is_expected.to have_many(:oraculs_lineups).class_name('::Oraculs::Lineup').dependent(:destroy) }
  end
end
