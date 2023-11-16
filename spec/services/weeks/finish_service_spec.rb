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

    it 'does not update week', :aggregate_failures do
      expect(service_call.success?).to be_truthy
      expect(week).not_to have_received(:update)
    end
  end

  context 'for not active week' do
    let!(:week) { create :week, status: Week::COMING }

    it 'does not update week', :aggregate_failures do
      expect(service_call.success?).to be_truthy
      expect(week.reload.status).not_to eq Week::FINISHED
    end
  end

  context 'for active week' do
    let!(:week) { create :week, status: Week::ACTIVE }

    it 'updates week', :aggregate_failures do
      expect(service_call.success?).to be_truthy
      expect(week.reload.status).to eq Week::FINISHED
    end
  end
end
