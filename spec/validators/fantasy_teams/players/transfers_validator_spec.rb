# frozen_string_literal: true

describe FantasyTeams::Players::TransfersValidator, type: :service do
  subject(:validator_call) { described_class.call(fantasy_team: fantasy_team, teams_players_ids: teams_players_ids) }

  let!(:season) { create :season, active: true }
  let!(:team) { create :team }
  let!(:seasons_team) { create :seasons_team, team: team, season: season }
  let!(:player1) { create :player, position_kind: Positionable::GOALKEEPER }
  let!(:player2) { create :player, position_kind: Positionable::GOALKEEPER }
  let!(:player3) { create :player, position_kind: Positionable::DEFENDER }
  let!(:teams_player1) { create :teams_player, player: player1, seasons_team: seasons_team, active: true }
  let!(:teams_player2) { create :teams_player, player: player2, seasons_team: seasons_team, active: true }
  let!(:teams_player3) { create :teams_player, player: player3, seasons_team: seasons_team, active: true }
  let!(:fantasy_team) { create :fantasy_team }
  let!(:fantasy_league) { create :fantasy_league, season: season }
  let(:teams_players_ids) {
    [
      teams_player1.id,
      teams_player2.id,
      teams_player3.id
    ]
  }

  before do
    create :fantasy_leagues_team, fantasy_league: fantasy_league, fantasy_team: fantasy_team

    allow(Sports).to receive(:sport).and_return({ 'max_team_players' => 3 })
    allow(Sports).to receive(:positions_for_sport).and_return({
      'football_goalkeeper' => {
        'name' => { 'en' => 'Goalkeeper', 'ru' => 'Вратарь' },
        'total_amount' => 2,
      },
      'football_defender' =>   {
        'name' => { 'en' => 'Defender', 'ru' => 'Защитник' },
        'total_amount' => 1,
      }
    })
  end

  context 'for invalid amount of players by positions' do
    let(:teams_players_ids) {
      [
        teams_player1.id,
        teams_player3.id
      ]
    }

    it 'result contains error' do
      expect(validator_call.first).to eq("Invalid players amount at position Goalkeeper")
    end
  end

  context 'for invalid amount of players from one team' do
    before do
      allow(Sports).to receive(:sport).and_return({ 'max_team_players' => 2 })
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
