# frozen_string_literal: true

describe FantasyTeams::TransfersController, type: :controller do
  describe 'GET#index' do
    context 'for unlogged users' do
      it 'redirects to login path' do
        get :index, params: { fantasy_team_id: 'unexisted', locale: 'en' }

        expect(response).to redirect_to users_login_en_path
      end
    end

    context 'for logged users' do
      sign_in_user

      context 'for not existed fantasy team' do
        it 'renders 404 page' do
          get :index, params: { fantasy_team_id: 'unexisted', locale: 'en' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existed not user fantasy team' do
        let!(:fantasy_team) { create :fantasy_team }

        it 'renders 404 page' do
          get :index, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existed user fantasy team' do
        let!(:fantasy_team) { create :fantasy_team, user: @current_user }

        before do
          create :fantasy_leagues_team, fantasy_team: fantasy_team
        end

        it 'renders index page' do
          get :index, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en' }

          expect(response).to render_template :index
        end
      end
    end
  end
end
