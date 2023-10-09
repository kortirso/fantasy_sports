# frozen_string_literal: true

describe Admin::LeaguesController do
  describe 'GET#index' do
    context 'for unlogged users' do
      it 'redirects to login path' do
        get :index, params: { locale: 'en' }

        expect(response).to redirect_to users_login_en_path
      end
    end

    context 'for logged users' do
      sign_in_user

      context 'for not authorized user' do
        it 'redirects to home path' do
          get :index, params: { locale: 'en' }

          expect(response).to redirect_to home_en_path
        end
      end

      context 'for authorized user' do
        before do
          create :league, sport_kind: 'football'

          @current_user.update(role: 'admin')
        end

        it 'renders index page' do
          get :index, params: { locale: 'en' }

          expect(response).to render_template :index
        end
      end
    end
  end

  describe 'GET#new' do
    context 'for unlogged users' do
      it 'redirects to login path' do
        get :new, params: { locale: 'en' }

        expect(response).to redirect_to users_login_en_path
      end
    end

    context 'for logged users' do
      sign_in_user

      context 'for not authorized user' do
        it 'redirects to home path' do
          get :new, params: { locale: 'en' }

          expect(response).to redirect_to home_en_path
        end
      end

      context 'for authorized user' do
        before do
          @current_user.update(role: 'admin')
        end

        it 'renders new page' do
          get :new, params: { locale: 'en' }

          expect(response).to render_template :new
        end
      end
    end
  end

  describe 'POST#create' do
    context 'for unlogged users' do
      it 'redirects to login path' do
        post :create, params: { league: {}, locale: 'en' }

        expect(response).to redirect_to users_login_en_path
      end
    end

    context 'for logged users' do
      sign_in_user

      context 'for not authorized user' do
        it 'redirects to home path' do
          post :create, params: { league: {}, locale: 'en' }

          expect(response).to redirect_to home_en_path
        end
      end

      context 'for authorized user' do
        before do
          @current_user.update(role: 'admin')
        end

        context 'for invalid params' do
          let(:request) { post :create, params: { league: { name_en: '' }, locale: 'en' } }

          it 'does not create league', :aggregate_failures do
            expect { request }.not_to change(League, :count)
            expect(response).to redirect_to new_admin_league_en_path
          end
        end

        context 'for valid params' do
          let(:request) {
            post :create, params: { league: { name_en: 'En', name_ru: 'Ru', sport_kind: 'football' }, locale: 'en' }
          }

          it 'creates league', :aggregate_failures do
            expect { request }.to change(League, :count).by(1)
            expect(response).to redirect_to admin_leagues_en_path
          end
        end
      end
    end
  end
end
