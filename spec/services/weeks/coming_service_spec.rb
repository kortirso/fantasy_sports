# frozen_string_literal: true

describe Weeks::ComingService, type: :service do
  subject(:service_call) {
    described_class.new(
      lineup_create_service: lineup_create_service
    ).call(week: week)
  }

  let(:lineup_create_service) { double }
  let!(:season) { create :season }
  let!(:fantasy_league) { create :fantasy_league, season: season }
  let!(:fantasy_team) { create :fantasy_team, season: season, completed: true }

  before do
    create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team

    allow(lineup_create_service).to receive(:call)
  end

  context 'for nil week' do
    let(:week) { nil }

    before do
      allow(week).to receive(:update)
    end

    it 'does not update week', :aggregate_failures do
      expect(service_call.success?).to be_truthy

      expect(week).not_to have_received(:update)
    end
  end

  context 'for existing week' do
    context 'for not inactive week' do
      let!(:week) { create :week, status: Week::ACTIVE, season: season }

      it 'does not update week', :aggregate_failures do
        expect(service_call.success?).to be_truthy

        expect(week.reload.status).not_to eq Week::COMING
        expect(lineup_create_service).not_to have_received(:call)
      end
    end

    context 'for inactive week' do
      let!(:week) { create :week, status: Week::INACTIVE, season: season }

      it 'updates week', :aggregate_failures do
        expect(service_call.success?).to be_truthy

        expect(week.reload.status).to eq Week::COMING
        expect(lineup_create_service).to have_received(:call).with(
          fantasy_team: fantasy_team,
          week: week
        )
      end
    end
  end
end
