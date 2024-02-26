# frozen_string_literal: true

describe Admin::FeedbacksController do
  describe 'GET#index' do
    context 'for unlogged users' do
      it 'redirects to login path' do
        get :index

        expect(response).to redirect_to users_login_path
      end
    end

    context 'for logged users' do
      sign_in_user

      context 'for not authorized user' do
        it 'redirects to home path' do
          get :index

          expect(response).to redirect_to draft_players_path
        end
      end

      context 'for authorized user' do
        before do
          @current_user.update(role: 'admin')
        end

        it 'renders index page' do
          get :index

          expect(response).to render_template :index
        end
      end
    end
  end
end
