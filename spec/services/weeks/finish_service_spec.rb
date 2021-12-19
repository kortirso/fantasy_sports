# frozen_string_literal: true

describe Weeks::FinishService, type: :service do
  subject(:service_call) {
    described_class.call(week: week)
  }

  context 'for nil week' do
    let(:week) { nil }

    before do
      allow(week).to receive(:update)
    end

    it 'does not update week' do
      service_call

      expect(week).not_to have_received(:update)
    end

    it 'and it succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end

  context 'for not active week' do
    let!(:week) { create :week, status: Week::COMING }

    it 'does not update week' do
      service_call

      expect(week.reload.status).not_to eq Week::INACTIVE
    end

    it 'and it succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end

  context 'for active week' do
    let!(:week) { create :week, status: Week::ACTIVE }

    it 'updates week' do
      service_call

      expect(week.reload.status).to eq Week::INACTIVE
    end

    it 'and it succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end
end
