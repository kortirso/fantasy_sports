# frozen_string_literal: true

describe Week, type: :model do
  it 'factory should be valid' do
    week = build :week

    expect(week).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:leagues_season).class_name('::Leagues::Season') }
    it { is_expected.to have_many(:games).dependent(:destroy) }
  end
end
