# frozen_string_literal: true

describe Games::UpdateForm, type: :service do
  subject(:form) { instance.call(game: game, params: { week_id: new_week.id }) }

  let!(:instance) { described_class.new }
  let!(:season) { create :season }
  let!(:new_week) { create :week, status: Week::INACTIVE, season: season }
  let!(:week) { create :week, status: Week::ACTIVE, season: season }
  let!(:game) { create :game, week: week }

  before { create :games_player, game: game }

  context 'when new week is not future' do
    before { new_week.update!(status: Week::ACTIVE) }

    it 'does not update game', :aggregate_failures do
      expect { form }.not_to change(Games::Player, :count)
      expect(form[:result]).to be_blank
      expect(game.reload.week).to eq week
    end
  end

  context 'when new week is coming' do
    before { new_week.update!(status: Week::COMING) }

    it 'does not update game', :aggregate_failures do
      expect { form }.not_to change(Games::Player, :count)
      expect(form[:errors]).to be_blank
      expect(game.reload.week).to eq new_week
    end
  end

  context 'for valid params' do
    it 'updates game', :aggregate_failures do
      expect { form }.to change(Games::Player, :count).by(-1)
      expect(form[:errors]).to be_blank
      expect(game.reload.week).to eq new_week
    end
  end
end
