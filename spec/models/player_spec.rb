# frozen_string_literal: true

describe Player, type: :model do
  it 'factory should be valid' do
    player = build :player

    expect(player).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:sports_position).class_name('Sports::Position') }
  end
end
