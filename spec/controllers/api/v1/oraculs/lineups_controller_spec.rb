# frozen_string_literal: true

describe Api::V1::Oraculs::LineupsController do
  describe 'GET#show' do
    it_behaves_like 'required api auth'
    it_behaves_like 'required api email confirmation'
    it_behaves_like 'required api available email'

    context 'for logged users' do
      let!(:user) { create :user }
      let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }

      context 'for not existing oracul' do
        it 'returns not found error' do
          do_request(access_token)

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing oracul' do
        let!(:oracul) { create :oracul }
        let!(:week) { create :week, season: oracul.oracul_place.placeable }

        context 'for not existing week' do
          it 'returns oraculs lineup data', :aggregate_failures do
            get :show, params: {
              oracul_id: oracul.id, week_id: 'unexisting', api_access_token: access_token, response_include_fields: 'id'
            }

            expect(response).to have_http_status :not_found
          end
        end

        context 'for not existing lineup' do
          it 'returns oraculs lineup data', :aggregate_failures do
            get :show, params: {
              oracul_id: oracul.id, api_access_token: access_token, response_include_fields: 'id'
            }

            expect(response).to have_http_status :ok
            expect(response.parsed_body.dig('oraculs_lineup', 'data')).to be_nil
          end
        end

        context 'for existing lineup' do
          let!(:oraculs_lineup) { create :oraculs_lineup, oracul: oracul, periodable: week }

          it 'returns oraculs lineup data', :aggregate_failures do
            get :show, params: {
              oracul_id: oracul.id, week_id: week.id, api_access_token: access_token, response_include_fields: 'id'
            }

            expect(response).to have_http_status :ok

            attributes = response.parsed_body.dig('oraculs_lineup', 'data', 'attributes')
            expect(attributes['id']).to eq oraculs_lineup.id
          end
        end
      end
    end

    def do_request(access_token=nil)
      get :show, params: { oracul_id: 'unexisting', api_access_token: access_token }.compact
    end
  end
end
