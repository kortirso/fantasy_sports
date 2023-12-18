# frozen_string_literal: true

describe Identities::CreateForm, type: :service do
  subject(:form) { instance.call(user: user, params: params) }

  let!(:instance) { described_class.new }
  let!(:user) { create :user }

  context 'for invalid params' do
    let(:params) { { uid: '' } }

    it 'does not create identity', :aggregate_failures do
      expect { form }.not_to change(Identity, :count)
      expect(form[:errors]).not_to be_blank
    end
  end

  context 'for valid params' do
    let(:params) { { uid: '1234', login: 'name', provider: 'telegram' } }

    it 'creates identity', :aggregate_failures do
      expect { form }.to change(user.identities, :count).by(1)
      expect(form[:result].is_a?(Identity)).to be_truthy
    end
  end
end
