# frozen_string_literal: true

describe Seasons::Team, type: :model do
  it 'factory should be valid' do
    seasons_team = build :seasons_team

    expect(seasons_team).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:season).class_name('::Season') }
    it { is_expected.to belong_to(:team).class_name('::Team') }
    it { is_expected.to have_many(:teams_players).class_name('Teams::Player').dependent(:destroy) }
    it { is_expected.to have_many(:players).through(:teams_players) }
    it { is_expected.to have_many(:active_teams_players).class_name('Teams::Player') }
    it { is_expected.to have_many(:active_players).through(:active_teams_players) }
    it { is_expected.to have_many(:home_season_games).class_name('Game').dependent(:destroy) }
    it { is_expected.to have_many(:visitor_season_games).class_name('Game').dependent(:destroy) }

    context 'for all games' do
      let(:seasons_team) { create :seasons_team }
      let!(:game1) { create :game, home_season_team: seasons_team }
      let!(:game2) { create :game, visitor_season_team: seasons_team }
      let!(:game3) { create :game }

      it 'returns only games for team', :aggregate_failures do
        result = seasons_team.games

        expect(result.size).to eq 2
        expect(result.pluck(:id).include?(game1.id)).to be_truthy
        expect(result.pluck(:id).include?(game2.id)).to be_truthy
        expect(result.pluck(:id).include?(game3.id)).to be_falsy
      end
    end
  end
end
