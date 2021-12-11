# frozen_string_literal: true

describe Game, type: :model do
  it 'factory should be valid' do
    game = build :game

    expect(game).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:week) }
    it { is_expected.to belong_to(:home_season_team).class_name('Seasons::Team') }
    it { is_expected.to belong_to(:visitor_season_team).class_name('Seasons::Team') }
    it { is_expected.to have_many(:games_players).class_name('::Games::Player').dependent(:destroy) }
    it { is_expected.to have_many(:teams_players).through(:games_players) }
  end
end
