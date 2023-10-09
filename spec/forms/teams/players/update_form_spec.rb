# frozen_string_literal: true

describe Teams::Players::UpdateForm, type: :service do
  subject(:form) { instance.call(teams_player: teams_player, params: params) }

  let!(:instance) { described_class.new }
  let!(:teams_player) { create :teams_player, price_cents: 1_000 }

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
      expect(form[:errors]).to be_nil
      expect(teams_player.reload.price_cents).to eq 123
    end
  end
end
