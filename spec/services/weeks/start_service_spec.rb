# frozen_string_literal: true

describe Weeks::StartService, type: :service do
  subject(:service_call) {
    described_class
      .new(price_change_service: price_change_service, form_change_service: form_change_service)
      .call(week: week)
  }

  let(:price_change_service) { double }
  let(:form_change_service) { double }

  before do
    allow(price_change_service).to receive(:call)
    allow(form_change_service).to receive(:call)
  end

  context 'for nil week' do
    let(:week) { nil }

    before do
      allow(week).to receive(:update)
    end

    it 'does not update week' do
      service_call

      expect(week).not_to have_received(:update)
    end

    it 'does not call price_change_service' do
      service_call

      expect(price_change_service).not_to have_received(:call)
    end

    it 'does not call form_change_service' do
      service_call

      expect(form_change_service).not_to have_received(:call)
    end

    it 'succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end

  context 'for existing week' do
    context 'for not coming week' do
      let!(:week) { create :week, status: Week::INACTIVE }

      it 'does not update week' do
        service_call

        expect(week.reload.status).not_to eq Week::ACTIVE
      end

      it 'does not call price_change_service' do
        service_call

        expect(price_change_service).not_to have_received(:call)
      end

      it 'does not call form_change_service' do
        service_call

        expect(form_change_service).not_to have_received(:call)
      end

      it 'succeed' do
        service = service_call

        expect(service.success?).to be_truthy
      end
    end

    context 'for coming week' do
      let!(:previous_week) { create :week, status: Week::FINISHED, position: 1 }
      let!(:week) { create :week, status: Week::COMING, position: 2, season: previous_week.season }
      let!(:game1) { create :game, week: previous_week }
      let!(:game2) { create :game, week: week }

      it 'updates week' do
        service_call

        expect(week.reload.status).to eq Week::ACTIVE
      end

      it 'calls price_change_service' do
        service_call

        expect(price_change_service).to have_received(:call).with(week: week)
      end

      it 'calls form_change_service' do
        service_call

        expect(form_change_service).to have_received(:call).with(games_ids: [game1.id, game2.id])
      end

      it 'succeed' do
        service = service_call

        expect(service.success?).to be_truthy
      end
    end
  end
end
