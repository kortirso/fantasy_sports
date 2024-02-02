# frozen_string_literal: true

describe Admin::Seasons::GamesController do
  let!(:season) { create :season }
  let!(:week) { create :week, season: season }

  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'
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
          get :index, params: { season_id: season.uuid, locale: 'en' }

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
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'
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
          get :new, params: { season_id: season.uuid, locale: 'en' }

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
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'
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
        let!(:week) { create :week, season: season }
        let!(:game) { create :game, week: week }

        it 'renders edit template' do
          get :edit, params: { season_id: season.uuid, id: game.uuid, locale: 'en' }

          expect(response).to render_template :edit
        end
      end
    end

    def do_request
      get :edit, params: { season_id: 'unexisting', id: 'unexisting', locale: 'en' }
    end
  end

  describe 'POST#create' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'
    it_behaves_like 'required admin'

    context 'for admin' do
      sign_in_admin

      context 'for not existing season' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for invalid params' do
        let(:request) { post :create, params: { season_id: season.uuid, game: { week_id: week.id }, locale: 'en' } }

        it 'does not create game', :aggregate_failures do
          expect { request }.not_to change(Game, :count)
          expect(response).to redirect_to new_admin_season_game_path
        end
      end

      context 'for valid params' do
        let!(:seasons_team1) { create :seasons_team, season: season }
        let!(:seasons_team2) { create :seasons_team, season: season }

        context 'with start time' do
          let(:request) {
            post :create, params: {
              season_id: season.uuid,
              game: {
                week_id: week.id,
                home_season_team_id: seasons_team1.id,
                visitor_season_team_id: seasons_team2.id,
                start_at: '2024-01-31 12:51'
              },
              locale: 'en'
            }
          }

          it 'creates game', :aggregate_failures do
            expect { request }.to change(season.games, :count).by(1)
            expect(Game.last.start_at.strftime('%Y-%m-%d %H:%M')).to eq '2024-01-31 12:51'
            expect(response).to redirect_to admin_season_games_path
          end
        end

        context 'with week' do
          let(:request) {
            post :create, params: {
              season_id: season.uuid,
              game: {
                week_id: week.id, home_season_team_id: seasons_team1.id, visitor_season_team_id: seasons_team2.id
              },
              locale: 'en'
            }
          }

          it 'creates game', :aggregate_failures do
            expect { request }.to change(season.games, :count).by(1)
            expect(response).to redirect_to admin_season_games_path
          end
        end
      end
    end

    def do_request
      post :create, params: { season_id: 'unexisting', game: { week_id: week.id }, locale: 'en' }
    end
  end

  describe 'PATCH#update' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'
    it_behaves_like 'required admin'

    context 'for admin' do
      let!(:game) { create :game, week: week }

      sign_in_admin

      context 'for not existing season' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for not existing game' do
        it 'renders 404 page' do
          patch :update, params: { season_id: season.uuid, id: 'unexisting', game: { week_id: week.id }, locale: 'en' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for invalid params' do
        it 'does not update game', :aggregate_failures do
          patch :update, params: {
            season_id: season.uuid, id: game.uuid, game: { week_id: 'unexisting' }, locale: 'en'
          }

          expect(game.reload.week_id).to eq week.id
          expect(response).to redirect_to edit_admin_season_game_path
        end
      end

      context 'for unexisting week id' do
        it 'does not update game', :aggregate_failures do
          patch :update, params: {
            season_id: season.uuid, id: game.uuid, game: { week_id: 777 }, locale: 'en'
          }

          expect(game.reload.week_id).to eq week.id
          expect(response).to redirect_to edit_admin_season_game_path
        end
      end

      context 'for empty week' do
        it 'updates game', :aggregate_failures do
          patch :update, params: {
            season_id: season.uuid, id: game.uuid, game: { week_id: '' }, locale: 'en'
          }

          expect(game.reload.week_id).to be_nil
          expect(response).to redirect_to admin_season_games_path
        end
      end

      context 'for valid params' do
        let!(:week2) { create :week, season: season }

        it 'updates game', :aggregate_failures do
          patch :update, params: {
            season_id: season.uuid, id: game.uuid, game: { week_id: week2.id }, locale: 'en'
          }

          expect(game.reload.week_id).to eq week2.id
          expect(response).to redirect_to admin_season_games_path
        end
      end
    end

    def do_request
      patch :update, params: { season_id: 'unexisting', id: 'unexisting', game: { week_id: week.id }, locale: 'en' }
    end
  end

  describe 'DELETE#destroy' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'
    it_behaves_like 'required admin'

    context 'for admin' do
      let!(:game) { create :game, week: week }

      sign_in_admin

      context 'for not existing season' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for not existing game' do
        it 'renders 404 page' do
          delete :destroy, params: { season_id: season.uuid, id: 'unexisting', locale: 'en' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing game' do
        let(:request) { delete :destroy, params: { season_id: season.uuid, id: game.uuid, locale: 'en' } }

        it 'destroys game', :aggregate_failures do
          expect { request }.to change(Game, :count).by(-1)
          expect(response).to redirect_to admin_season_games_path
        end
      end
    end

    def do_request
      delete :destroy, params: { season_id: 'unexisting', id: 'unexisting', locale: 'en' }
    end
  end
end
