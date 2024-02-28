# frozen_string_literal: true

describe OraculLeagues::Member do
  it 'factory should be valid' do
    oracul_leagues_member = build :oracul_leagues_member

    expect(oracul_leagues_member).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:oracul) }
    it { is_expected.to belong_to(:oracul_league) }
  end
end
