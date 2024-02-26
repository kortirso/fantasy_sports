# frozen_string_literal: true

describe OraculPlace do
  it 'factory should be valid' do
    oracul_place = build :oracul_place

    expect(oracul_place).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:placeable) }
    it { is_expected.to have_many(:oracul_leagues).dependent(:destroy) }
  end
end
