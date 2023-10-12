# frozen_string_literal: true

describe Weeks::TransfersController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      context 'for not existing week' do
        before { do_request }

        it 'returns status 404' do
          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing week' do
        let!(:week) { create :week }
        let!(:lineup) { create :lineup, week: week }

        before do
          create_list :transfer, 5, lineup: lineup

          get :index, params: { week_id: week.uuid, locale: 'en' }
        end

        it 'returns status 200' do
          expect(response).to have_http_status :ok
        end

        %w[transfers_in transfers_out].each do |attr|
          it "response contains week #{attr}" do
            expect(response.body).to have_json_path(attr)
          end
        end
      end
    end

    def do_request
      get :index, params: { week_id: 'unexisting', locale: 'en' }
    end
  end
end
