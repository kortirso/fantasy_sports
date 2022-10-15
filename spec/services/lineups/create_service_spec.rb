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
  let!(:fantasy_team) { create :fantasy_team }
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

    it 'does not create lineup' do
      expect { service_call }.not_to change(Lineup, :count)
    end

    it 'does not call lineup_players_creator' do
      service_call

      expect(lineup_players_creator).not_to have_received(:call)
    end

    it 'does not call lineup_players_copier' do
      service_call

      expect(lineup_players_copier).not_to have_received(:call)
    end

    it 'fails' do
      service = service_call

      expect(service.failure?).to be_truthy
    end
  end

  context 'for valid params' do
    context 'for first week' do
      it 'creates lineup' do
        expect { service_call }.to change(fantasy_team.lineups, :count).by(1)
      end

      it 'calls lineup_players_creator' do
        service_call

        expect(lineup_players_creator).to have_received(:call).with(lineup: Lineup.last)
      end

      it 'does not call lineup_players_copier' do
        service_call

        expect(lineup_players_copier).not_to have_received(:call)
      end

      it 'succeed' do
        service = service_call

        expect(service.success?).to be_truthy
      end
    end

    context 'for first lineup' do
      before { create :week, season: season, status: 'active', position: 0 }

      it 'creates lineup' do
        expect { service_call }.to change(fantasy_team.lineups, :count).by(1)
      end

      it 'calls lineup_players_creator' do
        service_call

        expect(lineup_players_creator).to have_received(:call).with(lineup: Lineup.last)
      end

      it 'does not call lineup_players_copier' do
        service_call

        expect(lineup_players_copier).not_to have_received(:call)
      end

      it 'succeed' do
        service = service_call

        expect(service.success?).to be_truthy
      end
    end

    context 'for second and later weeks with existing previous lineup' do
      let!(:previous_week) { create :week, season: season, status: 'active', position: 0 }
      let!(:previous_lineup) { create :lineup, week: previous_week, fantasy_team: fantasy_team }

      it 'creates lineup' do
        expect { service_call }.to change(fantasy_team.lineups, :count).by(1)
      end

      it 'does not call lineup_players_creator' do
        service_call

        expect(lineup_players_creator).not_to have_received(:call)
      end

      it 'calls lineup_players_copier' do
        service_call

        expect(lineup_players_copier).to(
          have_received(:call).with(lineup: Lineup.last, previous_lineup: previous_lineup)
        )
      end

      it 'succeed' do
        service = service_call

        expect(service.success?).to be_truthy
      end
    end
  end
end
