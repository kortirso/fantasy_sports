# frozen_string_literal: true

describe Weeks::FinishService, type: :service do
  subject(:service_call) { instance.call(week: week) }

  let!(:instance) { described_class.new }

  context 'for nil week' do
    let(:week) { nil }

    before do
      allow(week).to receive(:update)
    end

    it 'does not update week' do
      service_call

      expect(week).not_to have_received(:update)
    end
  end

  context 'for not active week' do
    let!(:week) { create :week, status: Week::COMING }

    it 'does not update week' do
      service_call

      expect(week.reload.status).not_to eq Week::FINISHED
    end
  end

  context 'for active week' do
    let!(:week) { create :week, status: Week::ACTIVE }

    it 'updates week' do
      service_call

      expect(week.reload.status).to eq Week::FINISHED
    end
  end
end
