# frozen_string_literal: true

describe OraculsController do
  describe 'GET#show' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'

    context 'for logged users' do
      sign_in_user

      context 'for not existing oracul' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing user oracul' do
        let!(:oracul) { create :oracul }

        it 'renders show page' do
          get :show, params: { id: oracul.uuid, locale: 'en' }

          expect(response).to render_template :show
        end
      end
    end

    def do_request
      get :show, params: { id: 'unexisting', locale: 'en' }
    end
  end
end