# frozen_string_literal: true

describe OraculLeague do
  it 'factory should be valid' do
    oracul_league = build :oracul_league

    expect(oracul_league).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:oracul_place) }
    it { is_expected.to belong_to(:leagueable).optional }
  end
end
