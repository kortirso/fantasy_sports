# frozen_string_literal: true

describe Api::Frontend::Games::StatisticsController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'

    context 'for logged users' do
      sign_in_user

      context 'for not existing game' do
        it 'returns json not_found status with errors' do
          do_request

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing game' do
        let!(:game) { create :game }

        it 'returns status 200' do
          get :index, params: { game_id: game.id, format: :json }

          expect(response).to have_http_status :ok
        end
      end
    end

    def do_request
      get :index, params: { game_id: 'unexisting', format: :json }
    end
  end
end
