# frozen_string_literal: true

describe Players::CreateValidator, type: :service do
  subject(:validator_call) { instance.call(params: params) }

  let!(:instance) { described_class.new }

  context 'for invalid name format' do
    let(:params) { { first_name: { en: '', ru: '' }, position_kind: 'basketball_center' } }

    it 'result contains error', :aggregate_failures do
      expect(validator_call).to include('First name is invalid')
      expect(validator_call).to include('Last name is missing')
    end
  end

  context 'for invalid position kind' do
    let(:params) {
      { first_name: { en: 'En', ru: 'Ru' }, last_name: { en: 'En', ru: 'Ru' }, position_kind: 'something' }
    }

    it 'result contains error' do
      expect(validator_call.first).to eq('Position kind is invalid')
    end
  end

  context 'for valid params' do
    let(:params) {
      { first_name: { en: 'En', ru: 'Ru' }, last_name: { en: 'En', ru: 'Ru' }, position_kind: 'basketball_center' }
    }

    it 'result does not contain errors' do
      expect(validator_call.empty?).to be_truthy
    end
  end
end
