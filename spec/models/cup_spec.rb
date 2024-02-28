# frozen_string_literal: true

describe Cup do
  it 'factory should be valid' do
    cup = build :cup

    expect(cup).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:league) }
    it { is_expected.to have_many(:oracul_places).dependent(:destroy) }
    it { is_expected.to have_many(:oracul_leagues).through(:oracul_places) }
    it { is_expected.to have_many(:oraculs).through(:oracul_places) }
  end
end
