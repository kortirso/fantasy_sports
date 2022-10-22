# frozen_string_literal: true

describe FantasyTeams::FantasyLeaguesController, type: :controller do
  describe 'GET#index' do
    context 'for unlogged users' do
      it 'redirects to login path' do
        get :index, params: { fantasy_team_id: 'unexisting', locale: 'en' }

        expect(response).to redirect_to users_login_en_path
      end
    end

    context 'for logged users' do
      sign_in_user

      context 'for not existing fantasy team' do
        it 'returns json not_found status with errors' do
          get :index, params: { fantasy_team_id: 'unexisting', locale: 'en' }

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing fantasy team of another user' do
        let!(:fantasy_team) { create :fantasy_team }

        it 'returns json not_found status with errors' do
          get :index, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en' }

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing fantasy team of user' do
        let!(:fantasy_team) { create :fantasy_team, user: @current_user }

        before do
          get :index, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en' }
        end

        it 'returns status 200' do
          expect(response).to have_http_status :ok
        end
      end
    end
  end
end
