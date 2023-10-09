# frozen_string_literal: true

describe Weeks::ChangeService, type: :service do
  subject(:service_call) {
    described_class.new(
      finish_service: finish_service,
      start_service: start_service,
      coming_service: coming_service
    ).call(week_id: week.id)
  }

  let(:finish_service) { double }
  let(:start_service) { double }
  let(:coming_service) { double }

  before do
    allow(finish_service).to receive(:call)
    allow(start_service).to receive(:call)
    allow(coming_service).to receive(:call)
  end

  context 'for unexisting coming week' do
    let(:week) { create :week, status: Week::INACTIVE }

    it 'does not call services', :aggregate_failures do
      service_call

      expect(finish_service).not_to have_received(:call)
      expect(start_service).not_to have_received(:call)
      expect(coming_service).not_to have_received(:call)
    end

    it 'and it fails' do
      service = service_call

      expect(service.failure?).to be_truthy
    end
  end

  context 'for existing coming week' do
    let!(:week) { create :week, status: Week::COMING }

    it 'calls services', :aggregate_failures do
      service_call

      expect(finish_service).to have_received(:call).with(week: week.previous)
      expect(start_service).to have_received(:call).with(week: week)
      expect(coming_service).to have_received(:call).with(week: week.next)
    end

    it 'and it succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end
end
