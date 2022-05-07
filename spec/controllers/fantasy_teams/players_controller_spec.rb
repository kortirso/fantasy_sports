# frozen_string_literal: true

describe FantasyTeams::PlayersController, type: :controller do
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

          expect(response.status).to eq 404
        end
      end

      context 'for existing fantasy team of another user' do
        let!(:fantasy_team) { create :fantasy_team }

        it 'returns json not_found status with errors' do
          get :index, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en' }

          expect(response.status).to eq 404
        end
      end

      context 'for existing fantasy team of user' do
        let!(:fantasy_team) { create :fantasy_team, user: @current_user }

        before do
          create :fantasy_teams_player, fantasy_team: fantasy_team

          get :index, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en' }
        end

        it 'returns status 200' do
          expect(response.status).to eq 200
        end

        %w[id price player team].each do |attr|
          it "and contains teams player #{attr}" do
            expect(response.body).to have_json_path("teams_players/data/0/attributes/#{attr}")
          end
        end

        %w[points statistic].each do |attr|
          it "and does not contain teams player #{attr}" do
            expect(response.body).not_to have_json_path("teams_players/data/0/attributes/player/#{attr}")
          end
        end
      end
    end
  end
end
