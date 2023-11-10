# frozen_string_literal: true

describe Users::CreateForm, type: :service do
  subject(:form) { instance.call(params: params) }

  let!(:instance) { described_class.new }

  context 'for invalid params' do
    let(:params) { { email: '1gmail.com', password: '1234qwer', password_confirmation: '1234qwer' } }

    it 'does not create User', :aggregate_failures do
      expect { form }.not_to change(User, :count)
      expect(form[:errors]).not_to be_blank
    end
  end

  context 'for valid params' do
    let(:params) { { email: '1@gmail.com', password: '1234qwer', password_confirmation: '1234qwer' } }

    it 'creates User', :aggregate_failures do
      expect { form }.to change(User, :count).by(1)
      expect(form[:errors]).to be_blank
    end
  end
end
