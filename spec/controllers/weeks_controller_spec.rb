# frozen_string_literal: true

describe WeeksController do
  describe 'GET#show' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      context 'for not existing week' do
        it 'returns json not_found status with errors' do
          do_request

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing week' do
        let!(:week) { create :week }

        context 'without additional fields' do
          before do
            get :show, params: { id: week.uuid, locale: 'en' }
          end

          it 'returns status 200' do
            expect(response).to have_http_status :ok
          end

          %w[uuid position deadline_at].each do |attr|
            it "contains week #{attr}" do
              expect(response.body).to have_json_path("week/data/attributes/#{attr}")
            end
          end

          %w[games previous next].each do |attr|
            it "does not contain week #{attr}" do
              expect(response.body).not_to have_json_path("week/data/attributes/#{attr}")
            end
          end
        end

        context 'with additional fields' do
          before do
            get :show, params: { id: week.uuid, locale: 'en', fields: 'games,previous,next' }
          end

          it 'returns status 200' do
            expect(response).to have_http_status :ok
          end

          %w[uuid position deadline_at games previous next].each do |attr|
            it "contains week #{attr}" do
              expect(response.body).to have_json_path("week/data/attributes/#{attr}")
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
