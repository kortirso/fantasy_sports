# frozen_string_literal: true

describe Games::ImportService, type: :service do
  subject(:service_call) { described_class.new(game_update_operation: game_update_operation).call(game: game) }

  let(:game_update_operation) { double }
  let(:scraper) { double }
  let!(:league) { create :league }
  let!(:season) { create :season, league: league }
  let!(:week) { create :week, season: season }
  let!(:game) { create :game, week: week }

  before do
    allow(game_update_operation).to receive(:call)
    allow(Football::SportsScraper).to receive(:new).and_return(scraper)
  end

  context 'for unexisting scraper' do
    before { game.update!(source: nil) }

    it 'does not call update operation' do
      service_call

      expect(game_update_operation).not_to have_received(:call)
    end
  end

  context 'for football sports' do
    before do
      league.update!(sport_kind: Sportable::FOOTBALL)
      game.update!(source: Sourceable::SPORTS)
    end

    context 'for invalid fetching' do
      before { allow(scraper).to receive(:call).and_raise(Games::ImportService::InvalidScrapingError) }

      it 'does not call update operation' do
        service_call

        expect(game_update_operation).not_to have_received(:call)
      end
    end

    context 'for valid fetching' do
      before { allow(scraper).to receive(:call).and_return([{ points: 1 }, { points: 2 }]) }

      it 'calls update operation' do
        service_call

        expect(game_update_operation).to have_received(:call)
      end
    end
  end
end
