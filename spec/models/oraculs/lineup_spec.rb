# frozen_string_literal: true

describe Oraculs::Lineup do
  it 'factory should be valid' do
    oraculs_lineup = build :oraculs_lineup

    expect(oraculs_lineup).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:oracul).class_name('::Oracul') }
    it { is_expected.to belong_to(:periodable) }
  end
end
