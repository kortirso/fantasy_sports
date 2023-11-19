# frozen_string_literal: true

describe Api::Frontend::PlayersSeasons::WatchesController do
  describe 'POST#create' do
    let!(:season) { create :season }
    let!(:players_season) { create :players_season, season: season }

    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      context 'for not existing player' do
        it 'returns json not_found status with errors' do
          do_request

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing player' do
        let(:request) { post :create, params: { players_season_id: players_season.uuid }, format: :json }

        context 'for not existing fantasy team' do
          it 'returns json not_found status with errors' do
            request

            expect(response).to have_http_status :not_found
          end
        end

        context 'for existing user fantasy team' do
          let!(:fantasy_team) { create :fantasy_team, season: season, user: @current_user }

          context 'for existing watch' do
            before { create :fantasy_teams_watch, fantasy_team: fantasy_team, players_season: players_season }

            it 'does not create watch', :aggregate_failures do
              expect { request }.not_to change(FantasyTeams::Watch, :count)
              expect(response).to have_http_status :ok
            end
          end

          context 'for not existing watch' do
            it 'creates watch', :aggregate_failures do
              expect { request }.to change(fantasy_team.fantasy_teams_watches, :count).by(1)
              expect(response).to have_http_status :ok
            end
          end
        end
      end
    end

    def do_request
      post :create, params: { players_season_id: 'unexisting' }, format: :json
    end
  end

  describe 'DELETE#destroy' do
    let!(:season) { create :season }
    let!(:players_season) { create :players_season, season: season }

    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      context 'for not existing player' do
        it 'returns json not_found status with errors' do
          do_request

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing player' do
        let(:request) { delete :destroy, params: { players_season_id: players_season.uuid }, format: :json }

        context 'for not existing fantasy team' do
          it 'returns json not_found status with errors' do
            request

            expect(response).to have_http_status :not_found
          end
        end

        context 'for existing user fantasy team' do
          let!(:fantasy_team) { create :fantasy_team, season: season, user: @current_user }

          context 'for not existing watch' do
            it 'does not destroy watch', :aggregate_failures do
              expect { request }.not_to change(FantasyTeams::Watch, :count)
              expect(response).to have_http_status :not_found
            end
          end

          context 'for existing watch' do
            before { create :fantasy_teams_watch, fantasy_team: fantasy_team, players_season: players_season }

            it 'destroys watch', :aggregate_failures do
              expect { request }.to change(fantasy_team.fantasy_teams_watches, :count).by(-1)
              expect(response).to have_http_status :ok
            end
          end
        end
      end
    end

    def do_request
      delete :destroy, params: { players_season_id: 'unexisting' }, format: :json
    end
  end
end
