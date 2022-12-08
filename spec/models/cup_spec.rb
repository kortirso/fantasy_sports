# frozen_string_literal: true

describe Cup do
  it 'factory should be valid' do
    cup = build :cup

    expect(cup).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:fantasy_league) }
    it { is_expected.to have_many(:cups_rounds).class_name('::Cups::Round').dependent(:destroy) }
  end
end
