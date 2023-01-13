# frozen_string_literal: true

describe LeagueValidator, type: :service do
  subject(:validator_call) { described_class.call(params: params) }

  context 'for invalid name format' do
    let(:params) { { name: { en: '', ru: '' }, sport_kind: 'football' } }

    it 'result contains error' do
      expect(validator_call.first).to eq('Name is invalid')
    end
  end

  context 'for invalid sport kind' do
    let(:params) { { name: { en: 'En', ru: 'Ru' }, sport_kind: 'something' } }

    it 'result contains error' do
      expect(validator_call.first).to eq('Sport kind is invalid')
    end
  end

  context 'for valid params' do
    let(:params) { { name: { en: 'En', ru: 'Ru' }, sport_kind: 'football' } }

    it 'result does not contain errors' do
      expect(validator_call.empty?).to be_truthy
    end
  end
end
