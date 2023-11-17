# frozen_string_literal: true

describe FantasyTeams::CompleteService, type: :service do
  subject(:service_call) {
    described_class.new(
      transfers_validator: transfers_validator,
      lineup_creator: lineup_creator
    ).call(fantasy_team: fantasy_team, params: params, teams_players_ids: [teams_player.id])
  }

  let!(:season) { create :season }
  let!(:fantasy_team) { create :fantasy_team, season: season }
  let!(:teams_player) { create :teams_player }
  let(:params) { { name: name, budget_cents: 500, favourite_team_uuid: favourite_team_uuid } }
  let(:transfers_validator) { double }
  let(:lineup_creator) { double }
  let(:lineup_creator_result) { double }
  let(:lineup) { create :lineup }
  let(:favourite_team_uuid) { nil }

  before do
    allow(lineup_creator).to receive(:call).and_return(lineup_creator_result)
    allow(lineup_creator_result).to receive(:result).and_return(lineup)

    create :fantasy_league, leagueable: season, season: season, name: 'Overall'
    fantasy_league = create :fantasy_league, season: season
    create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team
    create :week, season: season, status: Week::COMING
  end

  context 'for invalid params' do
    let(:name) { '' }

    it 'does not update fantasy team', :aggregate_failures do
      expect(service_call.failure?).to be_truthy
      expect(fantasy_team.reload.name).not_to eq name
      expect(lineup_creator).not_to have_received(:call)
    end

    it 'does not create fantasy team players' do
      expect { service_call }.not_to change(FantasyTeams::Player, :count)
    end

    it 'does not create transfers' do
      expect { service_call }.not_to change(Transfer, :count)
    end
  end

  context 'for invalid teams_players_ids params' do
    let(:name) { 'My new team' }

    before do
      allow(transfers_validator).to receive(:call).and_return(['Some error'])
    end

    it 'does not update fantasy team', :aggregate_failures do
      expect(service_call.failure?).to be_truthy
      expect(fantasy_team.reload.name).not_to eq name
      expect(lineup_creator).not_to have_received(:call)
    end

    it 'does not create fantasy team players' do
      expect { service_call }.not_to change(FantasyTeams::Player, :count)
    end

    it 'does not create transfers' do
      expect { service_call }.not_to change(Transfer, :count)
    end
  end

  context 'for valid params' do
    let(:name) { 'My new team' }

    before do
      allow(transfers_validator).to receive(:call).and_return([])
    end

    it 'updates fantasy team', :aggregate_failures do
      expect { service_call }.to(
        change(FantasyTeams::Player, :count).by(1)
          .and(change(Transfer, :count).by(1))
          .and(change(FantasyLeagues::Team, :count).by(1))
      )
      expect(fantasy_team.reload.name).to eq name
      expect(lineup_creator).to have_received(:call)
    end
  end

  context 'for existing favourite_team_uuid' do
    let!(:team) { create :team }
    let!(:fantasy_league) { create :fantasy_league, leagueable: team }
    let(:name) { 'My new team' }
    let(:favourite_team_uuid) { team.uuid }

    before do
      allow(transfers_validator).to receive(:call).and_return([])
    end

    it 'updates fantasy team', :aggregate_failures do
      expect { service_call }.to(
        change(FantasyTeams::Player, :count).by(1)
          .and(change(fantasy_league.members, :count).by(1))
          .and(change(FantasyLeagues::Team, :count).by(2))
      )
      expect(fantasy_team.reload.name).to eq name
      expect(lineup_creator).to have_received(:call)
    end
  end
end
