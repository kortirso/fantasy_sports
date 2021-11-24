# frozen_string_literal: true

describe HomesController, type: :controller do
  describe 'GET#show' do
    context 'for unlogged users' do
      it 'redirects to login path' do
        get :show, params: { locale: 'en' }

        expect(response).to redirect_to users_login_en_path
      end
    end

    context 'for logged users' do
      sign_in_user

      it 'renders show template' do
        get :show, params: { locale: 'en' }

        expect(response).to render_template :show
      end
    end
  end
end
