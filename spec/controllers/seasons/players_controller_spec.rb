# frozen_string_literal: true

describe Seasons::PlayersController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'

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
        let!(:players_season) { create :players_season, season: season }

        before do
          create :injury, players_season: players_season, return_at: nil

          get :index, params: { season_id: season.uuid, locale: 'en' }
        end

        it 'returns status 200', :aggregate_failures do
          expect(response).to have_http_status :ok
          expect(response.parsed_body.dig('season_players', 'data', 0, 'attributes', 'uuid')).to eq players_season.uuid
          %w[uuid player team form points average_points].each do |attr|
            expect(response.body).to have_json_path("season_players/data/0/attributes/#{attr}")
          end
          %w[name position_kind].each do |attr|
            expect(response.body).to have_json_path("season_players/data/0/attributes/player/#{attr}")
          end
          %w[uuid name price].each do |attr|
            expect(response.body).to have_json_path("season_players/data/0/attributes/team/#{attr}")
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
    it_behaves_like 'required available email'

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
        let!(:players_season) { create :players_season, season: season }

        before do
          create :teams_player, seasons_team: seasons_team, players_season: players_season

          get :show, params: { season_id: season.uuid, id: players_season.uuid, locale: 'en' }
        end

        it 'returns status 200', :aggregate_failures do
          expect(response).to have_http_status :ok
          %w[uuid player team form points average_points games_players selected_by_teams_ratio statistic].each do |attr|
            expect(response.body).to have_json_path("season_player/data/attributes/#{attr}")
          end
          %w[name position_kind].each do |attr|
            expect(response.body).to have_json_path("season_player/data/attributes/player/#{attr}")
          end
          %w[uuid name price].each do |attr|
            expect(response.body).to have_json_path("season_player/data/attributes/team/#{attr}")
          end
        end
      end
    end

    def do_request
      get :show, params: { season_id: 'unexisting', id: 'unexisting', locale: 'en' }
    end
  end
end
