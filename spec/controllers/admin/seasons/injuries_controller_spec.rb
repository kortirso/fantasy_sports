# frozen_string_literal: true

describe Admin::Seasons::InjuriesController do
  let!(:season) { create :season }
  let!(:players_season) { create :players_season, season: season }
  let!(:teams_player) { create :teams_player, players_season: players_season }

  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required admin'

    context 'for admin' do
      sign_in_admin

      context 'for not existing season' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing season' do
        it 'renders index template' do
          get :index, params: { season_id: season.id, locale: 'en' }

          expect(response).to render_template :index
        end
      end
    end

    def do_request
      get :index, params: { season_id: 'unexisting', locale: 'en' }
    end
  end

  describe 'GET#new' do
    it_behaves_like 'required auth'
    it_behaves_like 'required admin'

    context 'for admin' do
      sign_in_admin

      context 'for not existing season' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing season' do
        it 'renders new template' do
          get :new, params: { season_id: season.id, locale: 'en' }

          expect(response).to render_template :new
        end
      end
    end

    def do_request
      get :new, params: { season_id: 'unexisting', locale: 'en' }
    end
  end

  describe 'GET#edit' do
    it_behaves_like 'required auth'
    it_behaves_like 'required admin'

    context 'for admin' do
      sign_in_admin

      context 'for not existing season' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing season' do
        let!(:injury) { create :injury, players_season: players_season }

        context 'for not existing injury' do
          it 'renders 404 page' do
            do_request

            expect(response).to render_template 'shared/404'
          end
        end

        context 'for existing injury' do
          it 'renders edit template' do
            get :edit, params: { season_id: season.id, id: injury.id, locale: 'en' }

            expect(response).to render_template :edit
          end
        end
      end
    end

    def do_request
      get :edit, params: { season_id: 'unexisting', id: 'unexisting', locale: 'en' }
    end
  end

  describe 'POST#create' do
    it_behaves_like 'required auth'
    it_behaves_like 'required admin'

    context 'for admin' do
      sign_in_admin

      context 'for not existing season' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for not existing player' do
        it 'renders 404 page' do
          post :create, params: { season_id: season.id, injury: { teams_player_id: 1 }, locale: 'en' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for invalid params' do
        let(:request) {
          post :create, params: {
            season_id: season.id,
            injury: { reason_en: 'Reason', reason_ru: 'Reason', teams_player_id: teams_player.id }
          }
        }

        it 'does not create injury', :aggregate_failures do
          expect { request }.not_to change(Injury, :count)
          expect(response).to redirect_to new_admin_season_injury_path
        end
      end

      context 'for valid params' do
        let(:request) {
          post :create, params: {
            season_id: season.id,
            injury: {
              reason_en: 'Reason',
              reason_ru: 'Reason',
              teams_player_id: teams_player.id,
              return_at: '2023-01-01',
              status: 75
            }
          }
        }

        it 'creates injury', :aggregate_failures do
          expect { request }.to change(season.injuries, :count).by(1)
          expect(response).to redirect_to admin_season_injuries_path
        end
      end
    end

    def do_request
      post :create, params: { season_id: 'unexisting', injury: { teams_player_id: 1 }, locale: 'en' }
    end
  end

  describe 'PATCH#update' do
    it_behaves_like 'required auth'
    it_behaves_like 'required admin'

    context 'for admin' do
      let!(:injury) { create :injury, players_season: players_season, status: 75 }

      sign_in_admin

      context 'for not existing season' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for not existing injury' do
        it 'renders 404 page' do
          patch :update, params: { season_id: season.id, id: 'unexisting', injury: { teams_player_id: 1 } }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for invalid params' do
        it 'does not update injury', :aggregate_failures do
          patch :update, params: {
            season_id: season.id, id: injury.id, injury: { status: '' }
          }

          expect(injury.reload.status).to eq 75
          expect(response).to redirect_to edit_admin_season_injury_path
        end
      end

      context 'for unexisting teams_player_id' do
        it 'does not update injury', :aggregate_failures do
          patch :update, params: {
            season_id: season.id, id: injury.id, injury: { teams_player_id: 1 }
          }

          expect(injury.reload.players_season_id).to eq players_season.id
          expect(response).to render_template 'shared/404'
        end
      end

      context 'for valid params' do
        it 'updates injury', :aggregate_failures do
          patch :update, params: {
            season_id: season.id, id: injury.id, injury: { status: 25 }
          }

          expect(injury.reload.status).to eq 25
          expect(response).to redirect_to admin_season_injuries_path
        end
      end
    end

    def do_request
      patch :update, params: { season_id: 'unexisting', id: 'unexisting', injury: { teams_player_id: 1 } }
    end
  end

  describe 'DELETE#destroy' do
    it_behaves_like 'required auth'
    it_behaves_like 'required admin'

    context 'for admin' do
      let!(:injury) { create :injury, players_season: players_season }

      sign_in_admin

      context 'for not existing season' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for not existing injury' do
        it 'renders 404 page' do
          delete :destroy, params: { season_id: season.id, id: 'unexisting', locale: 'en' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing injury' do
        let(:request) { delete :destroy, params: { season_id: season.id, id: injury.id, locale: 'en' } }

        it 'destroys injury', :aggregate_failures do
          expect { request }.to change(Injury, :count).by(-1)
          expect(response).to redirect_to admin_season_injuries_path
        end
      end
    end

    def do_request
      delete :destroy, params: { season_id: 'unexisting', id: 'unexisting', locale: 'en' }
    end
  end
end
