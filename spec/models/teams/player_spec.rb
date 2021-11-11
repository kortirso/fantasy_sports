# frozen_string_literal: true

describe Teams::Player, type: :model do
  it 'factory should be valid' do
    teams_player = build :teams_player

    expect(teams_player).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:team) }
    it { is_expected.to belong_to(:player).class_name('::Player') }
  end
end
