# frozen_string_literal: true

describe Auth::GenerateToken do
  subject(:service_call) { described_class.call(user: user) }

  let!(:user) { create :user }

  context 'without existing session' do
    it 'succeeds', :aggregate_failures do
      expect(service_call.success?).to be_truthy
      expect(service_call.result.is_a?(String)).to be_truthy
    end

    it 'creates users session' do
      expect { service_call.result }.to change(Users::Session, :count).by(1)
    end
  end

  context 'with existing session' do
    let!(:users_session) { create :users_session, user: user }

    it 'succeeds', :aggregate_failures do
      service_call

      expect(service_call.success?).to be_truthy
      expect(Users::Session.find_by(id: users_session.id).nil?).to be_truthy
      expect(user.users_session.nil?).to be_falsy
      expect(service_call.result.is_a?(String)).to be_truthy
    end
  end
end
