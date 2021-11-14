# frozen_string_literal: true

describe Leagues::Seasons::Team, type: :model do
  it 'factory should be valid' do
    leagues_seasons_team = build :leagues_seasons_team

    expect(leagues_seasons_team).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:leagues_season).class_name('Leagues::Season') }
    it { is_expected.to belong_to(:team).class_name('::Team') }
    it { is_expected.to have_many(:teams_players).class_name('Teams::Player').dependent(:destroy) }
    it { is_expected.to have_many(:players).through(:teams_players) }
    it { is_expected.to have_many(:active_teams_players).class_name('Teams::Player') }
    it { is_expected.to have_many(:active_players).through(:active_teams_players) }
    it { is_expected.to have_many(:home_season_games).class_name('Game').with_foreign_key(:home_season_team_id).dependent(:destroy) }
    it { is_expected.to have_many(:visitor_season_games).class_name('Game').with_foreign_key(:visitor_season_team_id).dependent(:destroy) }

    context 'for all games' do
      let(:leagues_seasons_team) { create :leagues_seasons_team }
      let!(:game1) { create :game, home_season_team: leagues_seasons_team }
      let!(:game2) { create :game, visitor_season_team: leagues_seasons_team }
      let!(:game3) { create :game }

      it 'returns only games for team', :aggregate_failures do
        result = leagues_seasons_team.games

        expect(result.size).to eq 2
        expect(result.pluck(:id).include?(game1.id)).to be_truthy
        expect(result.pluck(:id).include?(game2.id)).to be_truthy
        expect(result.pluck(:id).include?(game3.id)).to be_falsy
      end
    end
  end
end
