# frozen_string_literal: true

describe Api::Frontend::WeeksController do
  describe 'GET#show' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'

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

        before do
          get :show, params: { id: week.id, format: :json }
        end

        it 'returns status 200', :aggregate_failures do
          expect(response).to have_http_status :ok
          %w[id position deadline_at previous_id next_id].each do |attr|
            expect(response.body).to have_json_path("week/data/attributes/#{attr}")
          end
        end
      end
    end

    def do_request
      get :show, params: { id: 'unexisting', format: :json }
    end
  end
end
