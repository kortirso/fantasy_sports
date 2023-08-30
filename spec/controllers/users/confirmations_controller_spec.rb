# frozen_string_literal: true

describe Users::ConfirmationsController do
  describe 'GET#complete' do
    before do
      allow(Users::UpdateService).to receive(:call)
    end

    context 'for unexisting user' do
      it 'renders failed_complete template' do
        get :complete, params: { email: 'unexisting@gmail.com', confirmation_token: '1', locale: 'en' }

        expect(response).to render_template :failed_complete
      end
    end

    context 'for existing user' do
      let(:user) { create :user, :not_confirmed }

      context 'for already confirmed user' do
        before { user.update(confirmed_at: DateTime.now) }

        it 'renders failed_complete template' do
          get :complete, params: { email: user.email, confirmation_token: '1', locale: 'en' }

          expect(response).to render_template :failed_complete
        end
      end

      context 'for invalid confirmation token' do
        it 'renders failed_complete template' do
          get :complete, params: { email: user.email, confirmation_token: '1', locale: 'en' }

          expect(response).to render_template :failed_complete
        end
      end

      context 'for valid confirmation token' do
        before do
          get :complete, params: { email: user.email, confirmation_token: user.confirmation_token, locale: 'en' }
        end

        it 'calls Users::UpdateService', :aggregate_failures do
          expect(Users::UpdateService).to have_received(:call)
          expect(response).to redirect_to home_en_path
        end
      end
    end
  end
end
