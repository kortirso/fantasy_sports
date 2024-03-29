# frozen_string_literal: true

describe Api::Frontend::FantasyTeams::PlayersController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required available email'

    context 'for logged users' do
      sign_in_user

      context 'for not existing fantasy team' do
        it 'returns json not_found status with errors' do
          do_request

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing team' do
        let!(:season) { create :season }
        let!(:fantasy_team) { create :fantasy_team, season: season }

        context 'for existing fantasy team of another user' do
          it 'returns json not_found status with errors' do
            get :index, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en' }

            expect(response).to have_http_status :not_found
          end
        end

        context 'for existing fantasy team of user' do
          before do
            fantasy_team.update!(user: @current_user)
            players_season = create :players_season, season: season
            teams_player = create :teams_player, players_season: players_season
            create :fantasy_teams_player, fantasy_team: fantasy_team, teams_player: teams_player
            create :week, season: season, status: Week::COMING

            get :index, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en' }
          end

          it 'returns status 200', :aggregate_failures do
            expect(response).to have_http_status :ok
            %w[uuid player team].each do |attr|
              expect(response.body).to have_json_path("teams_players/data/0/attributes/#{attr}")
            end
            %w[name position_kind].each do |attr|
              expect(response.body).to have_json_path("teams_players/data/0/attributes/player/#{attr}")
            end
            %w[uuid name price shirt_number].each do |attr|
              expect(response.body).to have_json_path("teams_players/data/0/attributes/team/#{attr}")
            end
          end
        end
      end
    end

    def do_request
      get :index, params: { fantasy_team_id: 'unexisting', locale: 'en' }
    end
  end
end
