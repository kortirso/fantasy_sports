# frozen_string_literal: true

describe FantasyTeams::PointsController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      context 'for not existing fantasy team' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing user fantasy team' do
        let!(:fantasy_team) { create :fantasy_team, user: @current_user }

        it 'renders index page' do
          get :index, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en' }

          expect(response).to render_template :index
        end
      end
    end

    def do_request
      get :index, params: { fantasy_team_id: 'unexisting', locale: 'en' }
    end
  end
end
