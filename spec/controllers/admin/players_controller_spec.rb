# frozen_string_literal: true

describe Admin::PlayersController do
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

          expect(response).to redirect_to home_path
        end
      end

      context 'for authorized user' do
        before do
          @current_user.update(role: 'admin')
        end

        it 'renders index page' do
          get :index, params: { locale: 'en' }

          expect(response).to render_template :index
        end

        context 'with sport kind' do
          it 'renders index page' do
            get :index, params: { locale: 'en', sport_kind: 'basketball' }

            expect(response).to render_template :index
          end
        end
      end
    end
  end

  describe 'GET#new' do
    context 'for unlogged users' do
      it 'redirects to login path' do
        get :new, params: { locale: 'en', sport_kind: 'basketball' }

        expect(response).to redirect_to users_login_path
      end
    end

    context 'for logged users' do
      sign_in_user

      context 'for not authorized user' do
        it 'redirects to home path' do
          get :new, params: { locale: 'en', sport_kind: 'basketball' }

          expect(response).to redirect_to home_path
        end
      end

      context 'for authorized user' do
        before do
          @current_user.update(role: 'admin')
        end

        it 'renders new page' do
          get :new, params: { locale: 'en', sport_kind: 'basketball' }

          expect(response).to render_template :new
        end
      end
    end
  end

  describe 'POST#create' do
    context 'for unlogged users' do
      it 'redirects to login path' do
        post :create, params: { player: {}, locale: 'en', sport_kind: 'basketball' }

        expect(response).to redirect_to users_login_path
      end
    end

    context 'for logged users' do
      sign_in_user

      context 'for not authorized user' do
        it 'redirects to home path' do
          post :create, params: { player: {}, locale: 'en', sport_kind: 'basketball' }

          expect(response).to redirect_to home_path
        end
      end

      context 'for authorized user' do
        before do
          @current_user.update(role: 'admin')
        end

        context 'for invalid params' do
          let(:request) {
            post :create, params: { player: { first_name_en: '' }, locale: 'en', sport_kind: 'basketball' }
          }

          it 'does not create player', :aggregate_failures do
            expect { request }.not_to change(Player, :count)
            expect(response).to redirect_to new_admin_player_path(sport_kind: 'basketball')
          end
        end

        context 'for valid params' do
          let(:request) {
            post :create, params: {
              player: {
                first_name_en: 'En',
                first_name_ru: 'Ru',
                last_name_en: 'En',
                last_name_ru: 'Ru',
                position_kind: 'basketball_center'
              },
              locale: 'en',
              sport_kind: 'basketball'
            }
          }

          it 'creates player', :aggregate_failures do
            expect { request }.to change(Player, :count).by(1)
            expect(response).to redirect_to admin_players_path(sport_kind: 'basketball')
          end
        end
      end
    end
  end
end
