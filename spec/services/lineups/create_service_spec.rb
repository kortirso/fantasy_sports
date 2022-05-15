# frozen_string_literal: true

describe Lineups::CreateService, type: :service do
  subject(:service_call) {
    described_class.new(
      lineup_players_creator: lineup_players_creator
    ).call(fantasy_team: fantasy_team)
  }

  let!(:season) { create :season, active: true }
  let!(:fantasy_league) {
    create :fantasy_league, leagueable: season, season: season, name: 'Overall'
  }
  let!(:week) { create :week, season: season, status: 'coming' }
  let!(:fantasy_team) { create :fantasy_team }
  let(:lineup_players_creator) { double }

  before do
    create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team

    allow(lineup_players_creator).to receive(:call)
  end

  context 'for invalid params' do
    before do
      create :lineup, fantasy_team: fantasy_team, week: week
    end

    it 'does not create lineup' do
      expect { service_call }.not_to change(Lineup, :count)
    end

    it 'and does not call lineup_players_creator' do
      service_call

      expect(lineup_players_creator).not_to have_received(:call)
    end

    it 'and it fails' do
      service = service_call

      expect(service.failure?).to be_truthy
    end
  end

  context 'for valid params' do
    it 'creates lineup' do
      expect { service_call }.to change(fantasy_team.lineups, :count).by(1)
    end

    it 'and calls lineup_players_creator' do
      service_call

      expect(lineup_players_creator).to have_received(:call)
    end

    it 'and it succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end
end
