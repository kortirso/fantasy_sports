# frozen_string_literal: true

describe RulesController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      it 'returns status 200' do
        get :index, params: { locale: 'en' }

        expect(response).to have_http_status :ok
      end
    end

    def do_request
      get :index, params: { locale: 'en' }
    end
  end
end
