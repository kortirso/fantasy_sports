# frozen_string_literal: true

describe Weeks::StartService, type: :service do
  subject(:service_call) {
    described_class
      .new(
        price_change_service: price_change_service,
        form_change_service: form_change_service,
        cup_create_service: cup_create_service,
        cups_pairs_generate_service: cups_pairs_generate_service,
        generate_week_position: generate_week_position
      )
      .call(week: week)
  }

  let(:price_change_service) { double }
  let(:form_change_service) { double }
  let(:cup_create_service) { double }
  let(:cups_pairs_generate_service) { double }
  let(:generate_week_position) { 2 }

  before do
    allow(price_change_service).to receive(:call)
    allow(form_change_service).to receive(:call)
    allow(cup_create_service).to receive(:call)
    allow(cups_pairs_generate_service).to receive(:call)
  end

  context 'for nil week' do
    let(:week) { nil }

    before do
      allow(week).to receive(:update)
    end

    it 'does not update week, does not call services and succeed', :aggregate_failures do
      service = service_call

      expect(week).not_to have_received(:update)
      expect(price_change_service).not_to have_received(:call)
      expect(form_change_service).not_to have_received(:call)
      expect(cup_create_service).not_to have_received(:call)
      expect(cups_pairs_generate_service).not_to have_received(:call)
      expect(service.success?).to be_truthy
    end
  end

  context 'for existing week' do
    context 'for not coming week' do
      let!(:week) { create :week, status: Week::INACTIVE }

      it 'does not update week, does not call services and succeed', :aggregate_failures do
        service = service_call

        expect(week.reload.status).not_to eq Week::ACTIVE
        expect(price_change_service).not_to have_received(:call)
        expect(form_change_service).not_to have_received(:call)
        expect(cup_create_service).not_to have_received(:call)
        expect(cups_pairs_generate_service).not_to have_received(:call)
        expect(service.success?).to be_truthy
      end
    end

    context 'for coming week' do
      let!(:previous_week) { create :week, status: Week::FINISHED, position: 1 }
      let!(:week) { create :week, status: Week::COMING, position: 2, season: previous_week.season }
      let!(:game1) { create :game, week: previous_week }
      let!(:game2) { create :game, week: week }
      let!(:fantasy_league) { create :fantasy_league, leagueable: previous_week.season, season: previous_week.season }

      before { create :lineup, week: week }

      it 'updates week, calls change_service and succeed', :aggregate_failures do
        expect { service_call }.to change(week.fantasy_leagues, :count).by(1)
        expect(week.reload.status).to eq Week::ACTIVE
        expect(price_change_service).to have_received(:call).with(week: week)
        expect(form_change_service).to have_received(:call).with(games_ids: [game1.id, game2.id])
        expect(cup_create_service).to have_received(:call).with(fantasy_league: fantasy_league)
        expect(cups_pairs_generate_service).not_to have_received(:call)
        expect(service_call.success?).to be_truthy
      end

      context 'when cup already exists' do
        before { create :cup, fantasy_league: fantasy_league }

        it 'calls services', :aggregate_failures do
          service = service_call

          expect(price_change_service).to have_received(:call).with(week: week)
          expect(form_change_service).to have_received(:call).with(games_ids: [game1.id, game2.id])
          expect(cup_create_service).not_to have_received(:call)
          expect(cups_pairs_generate_service).not_to have_received(:call)
          expect(service.success?).to be_truthy
        end
      end

      context 'for week after generate week position' do
        let(:generate_week_position) { 1 }

        it 'calls services', :aggregate_failures do
          service = service_call

          expect(price_change_service).to have_received(:call).with(week: week)
          expect(form_change_service).to have_received(:call).with(games_ids: [game1.id, game2.id])
          expect(cup_create_service).not_to have_received(:call)
          expect(cups_pairs_generate_service).to have_received(:call).with(week: week)
          expect(service.success?).to be_truthy
        end
      end
    end
  end
end
