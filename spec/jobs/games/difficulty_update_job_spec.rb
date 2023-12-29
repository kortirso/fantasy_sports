# frozen_string_literal: true

describe Games::DifficultyUpdateJob, type: :service do
  subject(:job_call) { described_class.perform_now(week_id: week_id) }

  let!(:week) { create :week }

  before do
    allow(FantasySports::Container.resolve('services.games.difficulty_update')).to receive(:call)
  end

  context 'for unexisting week' do
    let(:week_id) { 'unexisting' }

    it 'does not call service' do
      job_call

      expect(FantasySports::Container.resolve('services.games.difficulty_update')).not_to have_received(:call)
    end
  end

  context 'for existing games' do
    let(:week_id) { week.id }

    it 'calls service' do
      job_call

      expect(FantasySports::Container.resolve('services.games.difficulty_update')).to have_received(:call)
    end
  end
end
