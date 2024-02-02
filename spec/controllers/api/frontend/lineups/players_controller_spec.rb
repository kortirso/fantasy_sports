# frozen_string_literal: true

describe Api::Frontend::Lineups::PlayersController do
  describe 'GET#show' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'

    context 'for logged users' do
      sign_in_user

      context 'for not existing lineup' do
        it 'returns json not_found status with errors' do
          do_request

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing lineup of another user' do
        let!(:lineup) { create :lineup }

        context 'for not active week' do
          it 'returns json not_found status with errors' do
            get :show, params: { lineup_id: lineup.uuid, locale: 'en' }

            expect(response).to have_http_status :not_found
          end
        end

        context 'for active week' do
          before do
            lineup.week.update(status: Week::ACTIVE)

            lineups_player = create :lineups_player, lineup: lineup
            create :injury, players_season: lineups_player.teams_player.players_season, return_at: nil

            get :show, params: { lineup_id: lineup.uuid, locale: 'en' }
          end

          it 'returns status 200', :aggregate_failures do
            expect(response).to have_http_status :ok
            %w[uuid change_order points player team teams_player].each do |attr|
              expect(response.body).to have_json_path("lineup_players/data/0/attributes/#{attr}")
            end
          end
        end
      end

      context 'for existing lineup of user' do
        let!(:fantasy_team) { create :fantasy_team, user: @current_user }
        let!(:season) { create :season }
        let!(:week1) { create :week, position: 1, season: season }
        let!(:week2) { create :week, position: 2, season: season }
        let!(:teams_player) { create :teams_player }
        let!(:lineup) { create :lineup, fantasy_team: fantasy_team, week: week2 }
        let!(:lineup2) { create :lineup, fantasy_team: fantasy_team, week: week1 }

        context 'without additional fields' do
          before { create :lineups_player, lineup: lineup }

          it 'returns status 200', :aggregate_failures do
            get :show, params: { lineup_id: lineup.uuid, locale: 'en' }

            expect(response).to have_http_status :ok
            %w[uuid change_order points player team teams_player].each do |attr|
              expect(response.body).to have_json_path("lineup_players/data/0/attributes/#{attr}")
            end
          end
        end

        context 'with week_statistic additional field' do
          before { create :lineups_player, lineup: lineup }

          it 'returns status 200', :aggregate_failures do
            get :show, params: { lineup_id: lineup.uuid, fields: 'week_statistic,last_points' }

            expect(response).to have_http_status :ok
            %w[uuid change_order points player team teams_player week_statistic].each do |attr|
              expect(response.body).to have_json_path("lineup_players/data/0/attributes/#{attr}")
            end
          end
        end

        context 'with fixtures additional field' do
          before do
            create :lineups_player, lineup: lineup, teams_player: teams_player, points: 2
            create :lineups_player, lineup: lineup2, teams_player: teams_player, points: 1
          end

          it 'returns status 200', :aggregate_failures do
            get :show, params: { lineup_id: lineup.uuid, fields: 'fixtures,last_points' }

            expect(response).to have_http_status :ok
            %w[uuid change_order points player team teams_player fixtures last_points].each do |attr|
              expect(response.body).to have_json_path("lineup_players/data/0/attributes/#{attr}")
            end
          end
        end
      end
    end

    def do_request
      get :show, params: { lineup_id: 'unexisting' }
    end
  end
end
