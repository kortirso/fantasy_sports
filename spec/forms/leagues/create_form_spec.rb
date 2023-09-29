# frozen_string_literal: true

describe Leagues::CreateForm, type: :service do
  subject(:service_call) { described_class.call(params: params) }

  context 'for invalid params' do
    let(:params) { { name: { en: '' }, sport_kind: '' } }

    it 'does not create League', :aggregate_failures do
      expect { service_call }.not_to change(League, :count)
      expect(service_call.failure?).to be_truthy
    end
  end

  context 'for valid params' do
    let(:params) { { name: { en: 'league' }, sport_kind: 'football' } }

    it 'creates League', :aggregate_failures do
      expect { service_call }.to change(League, :count).by(1)
      expect(service_call.success?).to be_truthy
    end
  end
end
