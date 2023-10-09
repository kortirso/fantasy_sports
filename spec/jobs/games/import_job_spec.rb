# frozen_string_literal: true

describe Games::ImportJob, type: :service do
  subject(:job_call) { described_class.perform_now(game_id: game_id) }

  let!(:game) { create :game }

  before do
    allow(Games::ImportService).to receive(:call)
  end

  context 'for unexisting game' do
    let(:game_id) { 'unexisting' }

    it 'does not call service' do
      job_call

      expect(Games::ImportService).not_to have_received(:call)
    end
  end

  context 'for existing game' do
    let(:game_id) { game.id }

    it 'calls service' do
      job_call

      expect(Games::ImportService).to have_received(:call).with(game: game)
    end
  end
end
