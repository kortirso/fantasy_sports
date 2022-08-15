# frozen_string_literal: true

describe WeeksController, type: :controller do
  describe 'GET#show' do
    context 'for unlogged users' do
      it 'redirects to login path' do
        get :show, params: { id: 'unexisting', locale: 'en' }

        expect(response).to redirect_to users_login_en_path
      end
    end

    context 'for logged users' do
      sign_in_user

      context 'for not existing week' do
        it 'returns json not_found status with errors' do
          get :show, params: { id: 'unexisting', locale: 'en' }

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing week' do
        let!(:week) { create :week }

        context 'without additional fields' do
          before do
            get :show, params: { id: week.id, locale: 'en' }
          end

          it 'returns status 200' do
            expect(response).to have_http_status :ok
          end

          %w[id position date_deadline_at time_deadline_at].each do |attr|
            it "and contains week #{attr}" do
              expect(response.body).to have_json_path("week/data/attributes/#{attr}")
            end
          end

          %w[games previous next].each do |attr|
            it "and does not contain week #{attr}" do
              expect(response.body).not_to have_json_path("week/data/attributes/#{attr}")
            end
          end
        end

        context 'with additional fields' do
          before do
            get :show, params: { id: week.id, locale: 'en', fields: 'games,previous,next' }
          end

          it 'returns status 200' do
            expect(response).to have_http_status :ok
          end

          %w[id position date_deadline_at time_deadline_at games previous next].each do |attr|
            it "and contains week #{attr}" do
              expect(response.body).to have_json_path("week/data/attributes/#{attr}")
            end
          end
        end
      end
    end
  end
end
