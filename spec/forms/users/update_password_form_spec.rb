# frozen_string_literal: true

describe Users::UpdatePasswordForm, type: :service do
  subject(:form) { instance.call(user: user, params: params) }

  let!(:instance) { described_class.new }
  let!(:user) { create :user }

  context 'for invalid params' do
    let(:params) { { password: '1234qw', password_confirmation: '1234qwer' } }

    it 'does not update user', :aggregate_failures do
      expect { form }.not_to change(user, :password_digest)
      expect(form[:errors]).not_to be_blank
    end
  end

  context 'for valid params' do
    let(:params) { { password: '1234qwer', password_confirmation: '1234qwer' } }

    it 'updates user', :aggregate_failures do
      expect { form }.to change(user, :password_digest)
      expect(form[:errors]).to be_blank
    end
  end
end
