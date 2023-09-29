# frozen_string_literal: true

describe Lineups::CreateService, type: :service do
  subject(:service_call) {
    described_class.new(
      lineup_players_creator: lineup_players_creator,
      lineup_players_copier: lineup_players_copier
    ).call(fantasy_team: fantasy_team)
  }

  let!(:season) { create :season, active: true }
  let!(:fantasy_league) {
    create :fantasy_league, leagueable: season, season: season, name: 'Overall'
  }
  let!(:week) { create :week, season: season, status: 'coming', position: 1 }
  let!(:fantasy_team) { create :fantasy_team, season: season }
  let(:lineup_players_creator) { double }
  let(:lineup_players_copier) { double }

  before do
    create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team

    allow(lineup_players_creator).to receive(:call)
    allow(lineup_players_copier).to receive(:call)
  end

  context 'for invalid params' do
    before do
      create :lineup, fantasy_team: fantasy_team, week: week
    end

    it 'does not create lineup', :aggregate_failures do
      expect { service_call }.not_to change(Lineup, :count)
      expect(service_call.failure?).to be_truthy
      expect(lineup_players_creator).not_to have_received(:call)
      expect(lineup_players_copier).not_to have_received(:call)
    end
  end

  context 'for valid params' do
    context 'for first week' do
      it 'creates lineup', :aggregate_failures do
        expect { service_call }.to change(fantasy_team.lineups, :count).by(1)
        expect(service_call.success?).to be_truthy
        expect(lineup_players_creator).to have_received(:call).with(lineup: Lineup.last)
        expect(lineup_players_copier).not_to have_received(:call)
      end
    end

    context 'for first lineup' do
      before { create :week, season: season, status: 'active', position: 0 }

      it 'creates lineup', :aggregate_failures do
        expect { service_call }.to change(fantasy_team.lineups, :count).by(1)
        expect(service_call.success?).to be_truthy
        expect(lineup_players_creator).to have_received(:call).with(lineup: Lineup.last)
        expect(lineup_players_copier).not_to have_received(:call)
      end
    end

    context 'for second and later weeks with existing previous lineup' do
      let!(:previous_week) { create :week, season: season, status: 'active', position: 0 }
      let!(:previous_lineup) { create :lineup, week: previous_week, fantasy_team: fantasy_team }

      it 'creates lineup', :aggregate_failures do
        expect { service_call }.to change(fantasy_team.lineups, :count).by(1)
        expect(service_call.success?).to be_truthy
        expect(lineup_players_creator).not_to have_received(:call)
        expect(lineup_players_copier).to(
          have_received(:call).with(lineup: Lineup.last, previous_lineup: previous_lineup)
        )
      end
    end
  end
end
