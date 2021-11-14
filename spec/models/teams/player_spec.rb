# frozen_string_literal: true

describe Teams::Player, type: :model do
  it 'factory should be valid' do
    teams_player = build :teams_player

    expect(teams_player).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:leagues_seasons_team).class_name('::Leagues::Seasons::Team') }
    it { is_expected.to belong_to(:player).class_name('::Player') }
    it { is_expected.to have_many(:games_players).class_name('::Games::Player').with_foreign_key(:teams_player_id).dependent(:destroy) }
    it { is_expected.to have_many(:games).through(:games_players) }
  end
end
