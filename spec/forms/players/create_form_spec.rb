# frozen_string_literal: true

describe Players::CreateForm, type: :service do
  subject(:form) { instance.call(params: params) }

  let!(:instance) { described_class.new }

  context 'for invalid params' do
    let(:params) { { first_name: { en: '' }, position_kind: '' } }

    it 'does not create player', :aggregate_failures do
      expect { form }.not_to change(Player, :count)
      expect(form[:errors]).not_to be_nil
    end
  end

  context 'for valid params' do
    let(:params) { { first_name: { en: 'player' }, last_name: { en: 'player' }, position_kind: 'basketball_center' } }

    it 'creates player', :aggregate_failures do
      expect { form }.to change(Player, :count).by(1)
      expect(form[:errors]).to be_nil
    end
  end
end
