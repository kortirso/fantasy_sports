# frozen_string_literal: true

describe OraculLeaguesController do
  describe 'GET#show' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'

    context 'for logged confirmed users' do
      sign_in_user

      context 'for not existing oracul league' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing oracul league' do
        let!(:oracul_league) { create :oracul_league }

        it 'renders show template' do
          get :show, params: { id: oracul_league.uuid, locale: 'en' }

          expect(response).to render_template :show
        end
      end
    end

    def do_request
      get :show, params: { id: 'unexisting', locale: 'en' }
    end
  end
end
