# frozen_string_literal: true

describe Leagues::CreateForm, type: :service do
  subject(:form) { instance.call(params: params) }

  let!(:instance) { described_class.new }

  context 'for invalid params' do
    let(:params) { { name: { en: '' }, sport_kind: '' } }

    it 'does not create League', :aggregate_failures do
      expect { form }.not_to change(League, :count)
      expect(form[:errors]).not_to be_blank
    end
  end

  context 'for valid params' do
    let(:params) { { name: { en: 'league' }, sport_kind: 'football' } }

    it 'creates League', :aggregate_failures do
      expect { form }.to change(League, :count).by(1)
      expect(form[:errors]).to be_blank
    end
  end
end
