# frozen_string_literal: true

describe Admin::SeasonsController do
  describe 'GET#index' do
    context 'for unlogged users' do
      it 'redirects to login path' do
        get :index, params: { locale: 'en' }

        expect(response).to redirect_to users_login_path
      end
    end

    context 'for logged users' do
      sign_in_user

      context 'for not authorized user' do
        it 'redirects to home path' do
          get :index, params: { locale: 'en' }

          expect(response).to redirect_to draft_players_path
        end
      end

      context 'for authorized user' do
        before do
          create :season

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

        expect(response).to redirect_to users_login_path
      end
    end

    context 'for logged users' do
      sign_in_user

      context 'for not authorized user' do
        it 'redirects to home path' do
          get :new, params: { locale: 'en' }

          expect(response).to redirect_to draft_players_path
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
        post :create, params: { season: {}, locale: 'en' }

        expect(response).to redirect_to users_login_path
      end
    end

    context 'for logged users' do
      sign_in_user

      context 'for not authorized user' do
        it 'redirects to home path' do
          post :create, params: { season: {}, locale: 'en' }

          expect(response).to redirect_to draft_players_path
        end
      end

      context 'for authorized user' do
        let!(:league) { create :league }

        before do
          @current_user.update(role: 'admin')
        end

        context 'for invalid params' do
          let(:request) { post :create, params: { season: { name: '' }, locale: 'en' } }

          it 'does not create season', :aggregate_failures do
            expect { request }.not_to change(Season, :count)
            expect(response).to redirect_to new_admin_season_path
          end
        end

        context 'for invalid league' do
          let(:request) { post :create, params: { season: { name: 'En', league_id: 'unexisting' }, locale: 'en' } }

          it 'does not create season', :aggregate_failures do
            expect { request }.not_to change(Season, :count)
            expect(response).to redirect_to new_admin_season_path
          end
        end

        context 'for valid params' do
          let(:request) {
            post :create, params: { season: { name: 'En', league_id: league.id }, locale: 'en' }
          }

          it 'creates season', :aggregate_failures do
            expect { request }.to change(league.seasons, :count).by(1)
            expect(response).to redirect_to admin_seasons_path
          end
        end
      end
    end
  end
end
