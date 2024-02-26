# frozen_string_literal: true

describe FantasyCup do
  it 'factory should be valid' do
    fantasy_cup = build :fantasy_cup

    expect(fantasy_cup).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:fantasy_league) }
    it { is_expected.to have_many(:fantasy_cups_rounds).class_name('::FantasyCups::Round').dependent(:destroy) }
  end
end
