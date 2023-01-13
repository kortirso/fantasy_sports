# frozen_string_literal: true

describe FantasyTeamValidator, type: :service do
  subject(:validator_call) { described_class.call(params: params) }

  context 'for invalid name' do
    let(:params) { { name: '', budget_cents: 500 } }

    it 'result contains error' do
      expect(validator_call.first).to eq("Name can't be blank")
    end
  end

  context 'for invalid budget_cents' do
    let(:params) { { name: 'Ny Team', budget_cents: nil } }

    it 'result contains error' do
      expect(validator_call.first).to eq("Budget can't be blank")
    end
  end

  context 'for valid params' do
    let(:params) { { name: 'My team', budget_cents: 500 } }

    it 'result does not contain errors' do
      expect(validator_call.empty?).to be_truthy
    end
  end
end
