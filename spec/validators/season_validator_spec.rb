# frozen_string_literal: true

describe SeasonValidator, type: :service do
  subject(:validator_call) { described_class.new.call(params: params) }

  context 'for invalid name format' do
    let(:params) { { name: '', status: Season::ACTIVE } }

    it 'result contains error' do
      expect(validator_call.first).to eq("Name can't be blank")
    end
  end

  context 'for valid params' do
    let(:params) { { name: 'En', status: Season::ACTIVE } }

    it 'result does not contain errors' do
      expect(validator_call.empty?).to be_truthy
    end
  end
end
