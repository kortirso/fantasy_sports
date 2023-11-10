# frozen_string_literal: true

describe Games::UpdateForm, type: :service do
  subject(:form) { instance.call(game: game, params: { week_id: week.id }) }

  let!(:instance) { described_class.new }

  context 'for valid params' do
    let!(:week) { create :week }
    let!(:game) { create :game }

    it 'updates game', :aggregate_failures do
      expect(form[:errors]).to be_blank
      expect(game.reload.week).to eq week
    end
  end
end
