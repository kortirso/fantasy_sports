# frozen_string_literal: true

describe Users::RestoreController do
  describe 'GET#new' do
    it 'renders new template' do
      get :new, params: { locale: 'en' }

      expect(response).to render_template :new
    end
  end

  describe 'POST#create' do
    before { allow(FantasySports::Container.resolve('services.users.restore')).to receive(:call) }

    context 'for unexisting user' do
      it 'redirects to users_restore path' do
        post :create, params: { email: 'unexisting@gmail.com', locale: 'en' }

        expect(response).to redirect_to users_restore_path
      end
    end

    context 'for existing user' do
      let!(:user) { create :user }

      context 'for invalid email' do
        it 'does not call restore service', :aggregate_failures do
          post :create, params: { email: 'invalid@gmail.com', locale: 'en' }

          expect(FantasySports::Container.resolve('services.users.restore')).not_to(
            have_received(:call)
          )
          expect(response).to redirect_to users_restore_path
        end
      end

      context 'for valid email' do
        it 'calls restore service', :aggregate_failures do
          post :create, params: { email: user.email.upcase, locale: 'en' }

          expect(FantasySports::Container.resolve('services.users.restore')).to(
            have_received(:call).with(user: user)
          )
          expect(response).to redirect_to users_restore_path
        end
      end
    end
  end
end
