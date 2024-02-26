# frozen_string_literal: true

describe Oracul do
  it 'factory should be valid' do
    oracul = build :oracul

    expect(oracul).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:oracul_place) }
    it { is_expected.to have_many(:oracul_leagues_members).class_name('::OraculLeagues::Member').dependent(:destroy) }
    it { is_expected.to have_many(:oracul_leagues).through(:oracul_leagues_members) }
  end
end
