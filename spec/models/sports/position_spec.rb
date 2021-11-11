# frozen_string_literal: true

describe Sports::Position, type: :model do
  it 'factory should be valid' do
    sports_position = build :sports_position

    expect(sports_position).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:sport) }
    it { is_expected.to have_many(:players).dependent(:nullify) }
  end
end
