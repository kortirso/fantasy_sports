# frozen_string_literal: true

describe Auth::GenerateTokenService do
  subject(:service_call) { described_class.new.call(user: user) }

  let!(:user) { create :user }

  context 'without existing session' do
    it 'succeeds', :aggregate_failures do
      expect { service_call }.to change(Users::Session, :count).by(1)
      expect(service_call[:errors]).to be_blank
      expect(service_call[:result].is_a?(String)).to be_truthy
    end
  end

  context 'with existing session' do
    let!(:users_session) { create :users_session, user: user }

    it 'succeeds', :aggregate_failures do
      service_call

      expect(service_call[:errors]).to be_blank
      expect(Users::Session.find_by(id: users_session.id).nil?).to be_truthy
      expect(user.users_session.nil?).to be_falsy
      expect(service_call[:result].is_a?(String)).to be_truthy
    end
  end
end
