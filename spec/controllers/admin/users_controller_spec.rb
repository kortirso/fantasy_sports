# frozen_string_literal: true

describe Admin::UsersController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'
    it_behaves_like 'required admin'

    context 'for authorized user' do
      before { create :user }

      sign_in_admin

      it 'renders index page' do
        do_request

        expect(response).to render_template :index
      end
    end

    def do_request
      get :index, params: { locale: 'en' }
    end
  end
end
