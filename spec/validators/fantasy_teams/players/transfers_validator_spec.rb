# frozen_string_literal: true

require 'frozen_record/test_helper'

describe FantasyTeams::Players::TransfersValidator, type: :service do
  subject(:validator_call) {
    described_class.new.call(fantasy_team: fantasy_team, teams_players_ids: teams_players_ids)
  }

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
    create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team
  end

  context 'for invalid amount of players from one team' do
    before do
      test_fixtures_base_path = Rails.root.join('spec/support/fixtures/lineups_players_create_service')
      FrozenRecord::TestHelper.load_fixture(Sport, test_fixtures_base_path)
      FrozenRecord::TestHelper.load_fixture(Sports::Position, test_fixtures_base_path)
    end

    after do
      FrozenRecord::TestHelper.unload_fixtures
    end

    it 'result contains error' do
      expect(validator_call.first).to eq("Too many players from team #{team.name['en']}")
    end
  end

  context 'with specific set of rules' do
    before do
      test_fixtures_base_path = Rails.root.join('spec/support/fixtures/fantasy_teams_players_transfers_validator')
      FrozenRecord::TestHelper.load_fixture(Sport, test_fixtures_base_path)
      FrozenRecord::TestHelper.load_fixture(Sports::Position, test_fixtures_base_path)
    end

    after do
      FrozenRecord::TestHelper.unload_fixtures
    end

    context 'for invalid amount of players by positions' do
      let(:teams_players_ids) {
        [
          teams_player1.id,
          teams_player3.id
        ]
      }

      it 'result contains error' do
        expect(validator_call.first).to eq('Invalid players amount at position Goalkeeper')
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
        expect(validator_call.empty?).to be_truthy
      end
    end
  end
end
