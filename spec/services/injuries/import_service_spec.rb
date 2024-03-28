# frozen_string_literal: true

describe Injuries::ImportService, type: :service do
  subject(:service_call) { described_class.new.call(season: season) }

  let!(:league) { create :league, slug: 'epl' }
  let!(:season) { create :season, league: league }
  let!(:players_season) { create :players_season }

  let(:scraper) { FantasySports::Container.resolve('scrapers.injuries.sportsgambler') }
  let(:scraper_result) { [] }

  before do
    allow(scraper).to receive(:call).and_return(scraper_result)
  end

  context 'for not supported league' do
    before { league.update!(slug: 'unexisting') }

    it 'does nothing', :aggregate_failures do
      service_call

      expect(scraper).not_to have_received(:call)
      expect(Injury.count).to eq 0
    end
  end

  context 'for supported league' do
    context 'when no data' do
      it 'does not create injuries', :aggregate_failures do
        service_call

        expect(scraper).to have_received(:call)
        expect(Injury.count).to eq 0
      end
    end

    context 'when data returned by scraper' do
      let(:scraper_result) {
        [
          {
            players_season_id: players_season.id,
            reason: { en: 'Injury' },
            return_at: nil,
            status: 25
          }
        ]
      }

      it 'creates injuries', :aggregate_failures do
        service_call

        expect(scraper).to have_received(:call)
        expect(Injury.count).to eq 1
      end
    end
  end
end
