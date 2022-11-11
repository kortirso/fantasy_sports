# frozen_string_literal: true

describe Admin::Seasons::GamesController do
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
end
