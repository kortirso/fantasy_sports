# frozen_string_literal: true

describe FantasyLeaguesController, type: :controller do
  describe 'GET#show' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged confirmed users' do
      sign_in_user

      context 'for not existing fantasy league' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing fantasy league' do
        let!(:fantasy_league) { create :fantasy_league }

        it 'renders show template' do
          get :show, params: { id: fantasy_league.uuid, locale: 'en' }

          expect(response).to render_template :show
        end
      end
    end

    def do_request
      get :show, params: { id: 'unexisting', locale: 'en' }
    end
  end
end
