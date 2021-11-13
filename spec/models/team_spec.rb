# frozen_string_literal: true

describe Team, type: :model do
  it 'factory should be valid' do
    team = build :team

    expect(team).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_many(:leagues_seasons_teams).class_name('Leagues::Seasons::Team').dependent(:destroy) }
    it { is_expected.to have_many(:leagues_seasons).through(:leagues_seasons_teams) }
    it { is_expected.to have_many(:home_games).class_name('Game').with_foreign_key(:home_team_id).dependent(:destroy) }
    it { is_expected.to have_many(:visitor_games).class_name('Game').with_foreign_key(:visitor_team_id).dependent(:destroy) }

    context 'for all games' do
      let(:team) { create :team }
      let!(:game1) { create :game, home_team: team }
      let!(:game2) { create :game, visitor_team: team }
      let!(:game3) { create :game }

      it 'returns only games for team', :aggregate_failures do
        result = team.games

        expect(result.size).to eq 2
        expect(result.pluck(:id).include?(game1.id)).to be_truthy
        expect(result.pluck(:id).include?(game2.id)).to be_truthy
        expect(result.pluck(:id).include?(game3.id)).to be_falsy
      end
    end
  end
end
