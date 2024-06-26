# frozen_string_literal: true

describe Users::SessionsController do
  describe 'GET#new' do
    it 'renders new template' do
      get :new, params: { locale: 'en' }

      expect(response).to render_template :new
    end
  end

  describe 'POST#create' do
    context 'for email' do
      context 'for unexisting user' do
        it 'renders new template' do
          post :create, params: { user: { login: 'unexisting@gmail.com', password: '1' }, locale: 'en' }

          expect(response).to redirect_to users_login_path
        end
      end

      context 'for existing user' do
        let(:user) { create :user }

        context 'for invalid password' do
          it 'renders new template' do
            post :create, params: { user: { login: user.email, password: 'invalid_password' }, locale: 'en' }

            expect(response).to redirect_to users_login_path
          end
        end

        context 'for empty password' do
          it 'renders new template' do
            post :create, params: { user: { login: user.email, password: '' }, locale: 'en' }

            expect(response).to redirect_to users_login_path
          end
        end

        context 'for valid password' do
          it 'redirects to dashboard path' do
            post :create, params: { user: { login: user.email, password: user.password }, locale: 'en' }

            expect(response).to redirect_to draft_players_path
          end
        end

        context 'for valid password and upcased email' do
          it 'redirects to dashboard path' do
            post :create, params: { user: { login: user.email.upcase, password: user.password }, locale: 'en' }

            expect(response).to redirect_to draft_players_path
          end

          context 'for banned user' do
            before { user.update!(banned_at: DateTime.now) }

            it 'renders new template' do
              post :create, params: { user: { login: user.email.upcase, password: user.password }, locale: 'en' }

              expect(response).to redirect_to users_login_path
            end
          end
        end
      end
    end

    context 'for username' do
      context 'for existing user' do
        let(:user) { create :user }

        context 'for invalid password' do
          it 'renders new template' do
            post :create, params: { user: { login: user.username, password: 'invalid_password' } }

            expect(response).to redirect_to users_login_path
          end
        end

        context 'for empty password' do
          it 'renders new template' do
            post :create, params: { user: { login: user.username, password: '' }, locale: 'en' }

            expect(response).to redirect_to users_login_path
          end
        end

        context 'for valid password' do
          it 'redirects to dashboard path' do
            post :create, params: { user: { login: user.username, password: user.password } }

            expect(response).to redirect_to draft_players_path
          end
        end

        context 'for banned user' do
          before { user.update!(banned_at: DateTime.now) }

          it 'renders new template' do
            post :create, params: { user: { login: user.username, password: user.password } }

            expect(response).to redirect_to users_login_path
          end
        end
      end
    end
  end

  describe 'GET#destroy' do
    it 'redirects to root path' do
      get :destroy, params: { locale: 'en' }

      expect(response).to redirect_to root_path
    end
  end
end
