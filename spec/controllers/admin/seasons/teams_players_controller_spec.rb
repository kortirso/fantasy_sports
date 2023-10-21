# frozen_string_literal: true

describe Admin::Seasons::TeamsPlayersController do
  let!(:season) { create :season }

  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
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
        let!(:seasons_team) { create :seasons_team, season: season }
        let!(:teams_player) { create :teams_player, seasons_team: seasons_team }

        it 'renders edit template' do
          get :edit, params: { season_id: season.uuid, id: teams_player.uuid, locale: 'en' }

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
    it_behaves_like 'required admin'

    context 'for admin' do
      let!(:seasons_team) { create :seasons_team, season: season }
      let!(:player) { create :player }

      sign_in_admin

      context 'for not existing season' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for invalid params' do
        let(:request) {
          post :create, params: {
            season_id: season.uuid, teams_player: { price_cents: '' }, locale: 'en'
          }
        }

        it 'does not create teams player', :aggregate_failures do
          expect { request }.not_to change(Teams::Player, :count)
          expect(response).to redirect_to new_admin_season_teams_player_path(season.uuid)
        end
      end

      context 'for valid params' do
        let(:request) {
          post :create, params: {
            season_id: season.uuid,
            teams_player: {
              player_id: player.id, seasons_team_id: seasons_team.id, price_cents: '1450', shirt_number: '1', form: '2'
            },
            locale: 'en'
          }
        }

        it 'creates teams player', :aggregate_failures do
          expect { request }.to change(season.teams_players, :count).by(1)
          expect(response).to redirect_to admin_season_teams_players_path(season.uuid)
        end
      end
    end

    def do_request
      post :create, params: { season_id: 'unexisting', teams_player: { active: false }, locale: 'en' }
    end
  end

  describe 'PATCH#update' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required admin'

    context 'for admin' do
      let!(:seasons_team) { create :seasons_team, season: season }
      let!(:teams_player) { create :teams_player, seasons_team: seasons_team }

      sign_in_admin

      context 'for not existing season' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for not existing teams_player' do
        it 'renders 404 page' do
          patch :update, params: {
            season_id: season.uuid, id: 'unexisting', teams_player: { active: false }, locale: 'en'
          }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for invalid params' do
        let(:request) {
          patch :update, params: {
            season_id: season.uuid, id: teams_player.uuid, teams_player: { price_cents: '' }, locale: 'en'
          }
        }

        it 'does not update teams player', :aggregate_failures do
          request

          expect(teams_player.reload.price_cents).not_to eq ''
          expect(response).to redirect_to edit_admin_season_teams_player_path(season.uuid, teams_player.uuid)
        end
      end

      context 'for valid params' do
        let(:request) {
          patch :update, params: {
            season_id: season.uuid, id: teams_player.uuid, teams_player: { price_cents: '1450' }, locale: 'en'
          }
        }

        it 'updates teams player', :aggregate_failures do
          request

          expect(teams_player.reload.price_cents).to eq 1_450
          expect(response).to redirect_to admin_season_teams_players_path(season.uuid)
        end
      end
    end

    def do_request
      patch :update, params: {
        season_id: 'unexisting', id: 'unexisting', teams_player: { active: false }, locale: 'en'
      }
    end
  end
end
