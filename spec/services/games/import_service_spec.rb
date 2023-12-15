# frozen_string_literal: true

describe Games::ImportService, type: :service do
  subject(:service_call) {
    described_class.new(update_service: update_service).call(game: game, main_external_source: Sourceable::SPORTS)
  }

  let(:update_service) { double }
  let(:scraper) { double }
  let!(:league) { create :league }
  let!(:season) { create :season, league: league }
  let!(:week) { create :week, season: season }
  let!(:game) { create :game, week: week }

  before do
    allow(update_service).to receive(:call)
    allow(Scrapers::Football::Sports).to receive(:new).and_return(scraper)
  end

  context 'for unexisting scraper' do
    it 'does not call update operation' do
      service_call

      expect(update_service).not_to have_received(:call)
    end
  end

  context 'for football sports' do
    before do
      league.update!(sport_kind: Sportable::FOOTBALL)
      create(:games_external_source, game: game, source: Sourceable::SPORTS)
    end

    context 'for invalid fetching' do
      before { allow(scraper).to receive(:call).and_raise(Games::ImportService::InvalidScrapingError) }

      it 'does not call update operation' do
        service_call

        expect(update_service).not_to have_received(:call)
      end
    end

    context 'for valid fetching' do
      before { allow(scraper).to receive(:call).and_return([{ points: 1 }, { points: 2 }]) }

      it 'calls update operation' do
        service_call

        expect(update_service).to have_received(:call)
      end
    end
  end
end
