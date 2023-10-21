# frozen_string_literal: true

describe Seasons::PlayersController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      context 'for not existing season' do
        before { do_request }

        it 'returns status 404' do
          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing season' do
        let!(:season) { create :season, active: true }
        let!(:seasons_team) { create :seasons_team, season: season }

        before do
          create_list :teams_player, 2, seasons_team: seasons_team

          get :index, params: { season_id: season.uuid, locale: 'en' }
        end

        it 'returns status 200', :aggregate_failures do
          expect(response).to have_http_status :ok
          %w[uuid price player team].each do |attr|
            expect(response.body).to have_json_path("season_players/data/0/attributes/#{attr}")
          end
          %w[points statistic].each do |attr|
            expect(response.body).to have_json_path("season_players/data/0/attributes/player/#{attr}")
          end
        end
      end
    end

    def do_request
      get :index, params: { season_id: 'unexisting', locale: 'en' }
    end
  end

  describe 'GET#show' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      context 'for not existing season' do
        before { do_request }

        it 'returns status 404' do
          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing season' do
        let!(:season) { create :season, active: true }
        let!(:seasons_team) { create :seasons_team, season: season }
        let!(:teams_player) { create :teams_player, seasons_team: seasons_team }

        before do
          get :show, params: { season_id: season.uuid, id: teams_player.uuid, locale: 'en' }
        end

        it 'returns status 200', :aggregate_failures do
          expect(response).to have_http_status :ok
          %w[uuid price player team].each do |attr|
            expect(response.body).to have_json_path("season_player/data/attributes/#{attr}")
          end
          %w[points statistic].each do |attr|
            expect(response.body).to have_json_path("season_player/data/attributes/player/#{attr}")
          end
        end
      end
    end

    def do_request
      get :show, params: { season_id: 'unexisting', id: 'unexisting', locale: 'en' }
    end
  end
end
