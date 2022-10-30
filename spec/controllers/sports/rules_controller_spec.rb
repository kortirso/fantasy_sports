# frozen_string_literal: true

describe Sports::RulesController, type: :controller do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      context 'for not existing sport' do
        it 'returns json not_found status with errors' do
          do_request

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing sport' do
        it 'returns status 200' do
          get :index, params: { sport_id: 'football', locale: 'en' }

          expect(response).to have_http_status :ok
        end
      end
    end

    def do_request
      get :index, params: { sport_id: 'unexisting', locale: 'en' }
    end
  end
end
