# frozen_string_literal: true

describe FantasyTeams::Players::TransfersValidator, type: :service do
  subject(:validator_call) { described_class.call(fantasy_team: fantasy_team, teams_players_ids: teams_players_ids) }

  let!(:leagues_season) { create :leagues_season, active: true }
  let!(:team) { create :team }
  let!(:leagues_seasons_team) { create :leagues_seasons_team, team: team, leagues_season: leagues_season }
  let!(:sports_position1) { create :sports_position, sport: leagues_season.league.sport, total_amount: 2 }
  let!(:sports_position2) { create :sports_position, sport: leagues_season.league.sport, total_amount: 1 }
  let!(:player1) { create :player, sports_position: sports_position1 }
  let!(:player2) { create :player, sports_position: sports_position1 }
  let!(:player3) { create :player, sports_position: sports_position2 }
  let!(:teams_player1) { create :teams_player, player: player1, leagues_seasons_team: leagues_seasons_team, active: true }
  let!(:teams_player2) { create :teams_player, player: player2, leagues_seasons_team: leagues_seasons_team, active: true }
  let!(:teams_player3) { create :teams_player, player: player3, leagues_seasons_team: leagues_seasons_team, active: true }
  let!(:fantasy_team) { create :fantasy_team }
  let!(:fantasy_league) { create :fantasy_league, leagues_season: leagues_season }
  let(:teams_players_ids) {
    [
      teams_player1.id,
      teams_player2.id,
      teams_player3.id
    ]
  }

  before do
    create :fantasy_leagues_team, fantasy_league: fantasy_league, fantasy_team: fantasy_team
    leagues_season.league.sport.update(max_team_players: 3)
  end

  context 'for invalid amount of players by positions' do
    let(:teams_players_ids) {
      [
        teams_player1.id,
        teams_player3.id
      ]
    }

    it 'result contains error' do
      expect(validator_call.first).to eq("Invalid players amount at position #{sports_position1.name['en']}")
    end
  end

  context 'for invalid amount of players from one team' do
    before do
      leagues_season.league.sport.update(max_team_players: 2)
    end

    it 'result contains error' do
      expect(validator_call.first).to eq("Too many players from team #{team.name['en']}")
    end
  end

  context 'for too huge price of players' do
    before do
      teams_player1.update(price_cents: FantasyTeams::Players::TransfersValidator::BUDGET_LIMIT_CENTS + 100)
    end

    it 'result contains error' do
      expect(validator_call.first).to eq("Fantasy team's price is too high")
    end
  end

  context 'for valid params' do
    it 'result does not contain errors' do
      expect(validator_call.size.zero?).to be_truthy
    end
  end
end
