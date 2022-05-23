# frozen_string_literal: true

describe Transfer, type: :model do
  it 'factory should be valid' do
    transfer = build :transfer

    expect(transfer).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:week) }
    it { is_expected.to belong_to(:fantasy_team) }
    it { is_expected.to belong_to(:teams_player) }
  end
end
