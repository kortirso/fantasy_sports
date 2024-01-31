# frozen_string_literal: true

describe Weeks::TransfersController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'

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
          create_list :transfer, 3, lineup: lineup, direction: Transfer::IN
          create_list :transfer, 2, lineup: lineup, direction: Transfer::OUT

          create :lineups_player, lineup: lineup
        end

        context 'for first week of season' do
          it 'returns status 200', :aggregate_failures do
            get :index, params: { week_id: week.uuid, locale: 'en' }

            expect(response).to have_http_status :ok
            expect(response.parsed_body['transfers_in'].size).to eq 1
            expect(response.parsed_body['transfers_out'].size).to eq 0

            %w[transfers_in transfers_out].each do |attr|
              expect(response.body).to have_json_path(attr)
            end
          end
        end

        context 'for week with previous' do
          before { create :week, position: week.position - 1, season: week.season }

          it 'returns status 200', :aggregate_failures do
            get :index, params: { week_id: week.uuid, locale: 'en' }

            expect(response).to have_http_status :ok
            expect(response.parsed_body['transfers_in'].size).to eq 3
            expect(response.parsed_body['transfers_out'].size).to eq 2

            %w[transfers_in transfers_out].each do |attr|
              expect(response.body).to have_json_path(attr)
            end
          end
        end
      end
    end

    def do_request
      get :index, params: { week_id: 'unexisting', locale: 'en' }
    end
  end
end
