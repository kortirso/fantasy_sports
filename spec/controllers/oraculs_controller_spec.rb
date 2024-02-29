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
        context 'for season' do
          let!(:season) { create :season }
          let!(:oracul_place) { create :oracul_place, placeable: season }
          let!(:oracul) { create :oracul, oracul_place: oracul_place }

          before { create :week, season: season }

          it 'renders show page' do
            get :show, params: { id: oracul.uuid, locale: 'en' }

            expect(response).to render_template :show
          end

          context 'with week_id' do
            it 'renders show page' do
              get :show, params: { id: oracul.uuid, week_id: 'unexisting', locale: 'en' }

              expect(response).to render_template :show
            end
          end
        end

        context 'for cup' do
          let!(:cup) { create :cup }
          let!(:oracul_place) { create :oracul_place, placeable: cup }
          let!(:oracul) { create :oracul, oracul_place: oracul_place }

          before { create :cups_round, cup: cup }

          it 'renders show page' do
            get :show, params: { id: oracul.uuid, locale: 'en' }

            expect(response).to render_template :show
          end

          context 'with week_id' do
            it 'renders show page' do
              get :show, params: { id: oracul.uuid, week_id: 'unexisting', locale: 'en' }

              expect(response).to render_template :show
            end
          end
        end
      end
    end

    def do_request
      get :show, params: { id: 'unexisting', locale: 'en' }
    end
  end
end
