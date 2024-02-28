# frozen_string_literal: true

describe Api::Frontend::Oraculs::ForecastsController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'

    context 'for logged users' do
      sign_in_user

      context 'for not existing lineup' do
        it 'returns json not_found status with errors' do
          do_request

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing lineup of another user' do
        let!(:week) { create :week }
        let!(:game) { create :game, week: week, start_at: 3.hours.after }
        let!(:oraculs_lineup) { create :oraculs_lineup, periodable: week }

        before { create :oraculs_forecast, oraculs_lineup: oraculs_lineup, forecastable: game }

        it 'returns json ok status', :aggregate_failures do
          get :index, params: { oraculs_lineup_id: oraculs_lineup.uuid }

          expect(response).to have_http_status :ok
          %w[uuid owner value forecastable].each do |attr|
            expect(response.body).to have_json_path("forecasts/data/0/attributes/#{attr}")
          end
        end

        context 'for user lineup' do
          before { oraculs_lineup.oracul.update!(user: @current_user) }

          it 'returns json ok status', :aggregate_failures do
            get :index, params: { oraculs_lineup_id: oraculs_lineup.uuid }

            expect(response).to have_http_status :ok
            %w[uuid owner value forecastable].each do |attr|
              expect(response.body).to have_json_path("forecasts/data/0/attributes/#{attr}")
            end
          end
        end
      end
    end

    def do_request
      get :index, params: { oraculs_lineup_id: 'unexisting' }
    end
  end

  describe 'PATCH#update' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'

    context 'for logged users' do
      sign_in_user

      context 'for not existing forecast' do
        it 'returns json not_found status with errors' do
          do_request

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing forecast' do
        let!(:oracul) { create :oracul }
        let!(:oraculs_lineup) { create :oraculs_lineup, oracul: oracul }
        let!(:game) { create :game, start_at: 1.hour.after }
        let!(:oraculs_forecast) do
          create :oraculs_forecast, oraculs_lineup: oraculs_lineup, forecastable: game, value: [3, 0]
        end

        let(:request) { patch :update, params: { id: oraculs_forecast.uuid, oraculs_forecast: { value: [3, 1] } } }

        it 'does not update forecast', :aggregate_failures do
          request

          expect(oraculs_forecast.reload.value).to eq([3, 0])
          expect(response).to have_http_status :ok
        end

        context 'for user lineup' do
          before { oracul.update!(user: @current_user) }

          it 'does not update forecast', :aggregate_failures do
            request

            expect(oraculs_forecast.reload.value).to eq([3, 0])
            expect(response).to have_http_status :ok
          end

          context 'for predictable game' do
            before { game.update!(start_at: 3.hours.after) }

            it 'updates forecast', :aggregate_failures do
              request

              expect(oraculs_forecast.reload.value).to eq([3, 1])
              expect(response).to have_http_status :ok
            end
          end
        end
      end
    end

    def do_request
      patch :update, params: { id: 'unexisting', oraculs_forecast: { value: [3, 1] } }
    end
  end
end