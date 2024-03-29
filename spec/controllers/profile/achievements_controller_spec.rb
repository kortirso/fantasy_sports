# frozen_string_literal: true

describe Profile::AchievementsController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required available email'

    context 'for logged users' do
      sign_in_user

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
