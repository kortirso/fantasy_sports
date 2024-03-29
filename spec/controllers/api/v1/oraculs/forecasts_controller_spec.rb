# frozen_string_literal: true

describe Api::V1::Oraculs::ForecastsController do
  describe 'PATCH#update' do
    it_behaves_like 'required api auth'
    it_behaves_like 'required api available email'

    context 'for logged users' do
      let!(:oracul) { create :oracul }
      let!(:oraculs_lineup) { create :oraculs_lineup, oracul: oracul }
      let!(:user) { create :user }
      let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }

      context 'for not existing forecast' do
        it 'returns json not_found status with errors' do
          do_request(access_token)

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing forecast' do
        let!(:game) { create :game, start_at: 1.hour.after }
        let!(:oraculs_forecast) do
          create :oraculs_forecast, oraculs_lineup: oraculs_lineup, forecastable: game, value: [3, 0]
        end

        let(:request) {
          patch :update, params: {
            id: oraculs_forecast.id,
            oraculs_forecast: { value: [3, 1] },
            api_access_token: access_token
          }
        }

        it 'does not update forecast', :aggregate_failures do
          request

          expect(oraculs_forecast.reload.value).to eq([3, 0])
          expect(response).to have_http_status :unprocessable_entity
        end

        context 'for user lineup' do
          before { oracul.update!(user: user) }

          it 'does not update forecast', :aggregate_failures do
            request

            expect(oraculs_forecast.reload.value).to eq([3, 0])
            expect(response).to have_http_status :unprocessable_entity
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

      context 'for elimination cup' do
        let!(:cups_pair) {
          create :cups_pair, start_at: 3.hours.after, elimination_kind: Cups::Pair::BEST_OF, required_wins: 3
        }
        let!(:oraculs_forecast) do
          create :oraculs_forecast, oraculs_lineup: oraculs_lineup, forecastable: cups_pair
        end

        before { oracul.update!(user: user) }

        context 'for invalid value of required_wins' do
          let(:request) {
            patch :update, params: {
              id: oraculs_forecast.id,
              oraculs_forecast: { value: [4, 1] },
              api_access_token: access_token
            }
          }

          it 'does not update forecast', :aggregate_failures do
            request

            expect(oraculs_forecast.reload.value).to be_empty
            expect(response).to have_http_status :unprocessable_entity
          end
        end

        context 'for valid value of required_wins' do
          let(:request) {
            patch :update, params: {
              id: oraculs_forecast.id,
              oraculs_forecast: { value: [3, 2] },
              api_access_token: access_token
            }
          }

          it 'updates forecast', :aggregate_failures do
            request

            expect(oraculs_forecast.reload.value).to eq([3, 2])
            expect(response).to have_http_status :ok
          end
        end
      end
    end

    def do_request(access_token=nil)
      patch :update, params: { id: 'unexisting', api_access_token: access_token }.compact
    end
  end
end
