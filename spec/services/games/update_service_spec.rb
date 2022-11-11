# frozen_string_literal: true

describe Games::UpdateService, type: :service do
  subject(:service_call) {
    described_class.call(
      game: game,
      params: {
        week_id: week.id
      }
    )
  }

  context 'for valid params' do
    let(:week) { create :week }
    let(:game) { create :game }

    it 'updates game' do
      service_call

      expect(game.reload.week).to eq week
    end

    it 'succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end
end
