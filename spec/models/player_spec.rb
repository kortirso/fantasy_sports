# frozen_string_literal: true

describe Player, type: :model do
  it 'factory should be valid' do
    player = build :player

    expect(player).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:sports_position).class_name('Sports::Position') }
    it { is_expected.to have_many(:teams_players).class_name('Teams::Player').dependent(:destroy) }
    it { is_expected.to have_many(:teams).through(:teams_players) }
    it { is_expected.to have_one(:active_teams_player).class_name('Teams::Player') }
    it { is_expected.to have_one(:active_team).through(:active_teams_player).class_name('::Team') }
  end
end
