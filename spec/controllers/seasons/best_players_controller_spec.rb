# frozen_string_literal: true

describe Seasons::BestPlayersController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
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
        let!(:week) { create :week, season: season }

        it 'returns status 200' do
          get :index, params: { season_id: season.uuid, locale: 'en' }

          expect(response).to have_http_status :ok
        end

        context 'with week uuid in params' do
          it 'returns status 200' do
            get :index, params: { season_id: season.uuid, week_uuid: week.uuid, locale: 'en' }

            expect(response).to have_http_status :ok
          end
        end
      end
    end

    def do_request
      get :index, params: { season_id: 'unexisting', locale: 'en' }
    end
  end
end
