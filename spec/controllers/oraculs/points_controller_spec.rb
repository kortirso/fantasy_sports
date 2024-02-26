# frozen_string_literal: true

describe Oraculs::PointsController do
  describe 'GET#index' do
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

        it 'renders index page' do
          get :index, params: { oracul_id: oracul.uuid, locale: 'en' }

          expect(response).to render_template :index
        end
      end
    end

    def do_request
      get :index, params: { oracul_id: 'unexisting', locale: 'en' }
    end
  end
end
