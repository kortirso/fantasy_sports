# frozen_string_literal: true

describe Teams::Players::UpdateForm, type: :service do
  subject(:form) { instance.call(teams_player: teams_player, params: params) }

  let!(:instance) { described_class.new }
  let!(:teams_player) { create :teams_player, price_cents: 1_000 }
  let!(:week1) { create :week, status: 'active' }
  let!(:week2) { create :week, status: 'coming' }
  let!(:week3) { create :week, status: 'inactive' }
  let!(:game1) { create :game, week: week1, points: [] }
  let!(:game2) { create :game, week: week1, points: [1, 2] }
  let!(:game3) { create :game, week: week2, points: [] }
  let!(:game4) { create :game, week: week3, points: [] }

  before do
    create :games_player, teams_player: teams_player, game: game1
    create :games_player, teams_player: teams_player, game: game2
    create :games_player, teams_player: teams_player, game: game3
    create :games_player, teams_player: teams_player, game: game4
  end

  context 'for invalid params' do
    let(:params) { { price_cents: 'abs' } }

    it 'does not update teams_player', :aggregate_failures do
      expect(form[:errors]).not_to be_blank
      expect(teams_player.reload.price_cents).to eq 1_000
    end
  end

  context 'for valid params' do
    let(:params) { { price_cents: 123 } }

    it 'updates teams_player', :aggregate_failures do
      expect { form }.not_to change(Games::Player, :count)
      expect(form[:errors]).to be_nil
      expect(teams_player.reload.price_cents).to eq 123
    end
  end

  context 'for valid params with active false' do
    let(:params) { { price_cents: 123, active: false } }

    it 'updates teams_player', :aggregate_failures do
      expect { form }.to change(Games::Player, :count).by(-2)
      expect(form[:errors]).to be_nil
      expect(teams_player.reload.price_cents).to eq 123
    end
  end
end
