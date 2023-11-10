# frozen_string_literal: true

describe FantasyTeams::FantasyLeaguesController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      context 'for not existing fantasy team' do
        it 'returns json not_found status with errors' do
          do_request

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing fantasy team of another user' do
        let!(:fantasy_team) { create :fantasy_team }

        it 'returns json not_found status with errors' do
          get :index, params: { fantasy_team_id: fantasy_team.uuid }

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing fantasy team of user' do
        let!(:fantasy_team) { create :fantasy_team, user: @current_user }

        it 'returns status 200' do
          get :index, params: { fantasy_team_id: fantasy_team.uuid }

          expect(response).to have_http_status :ok
        end
      end
    end

    def do_request
      get :index, params: { fantasy_team_id: 'unexisting' }
    end
  end
end
