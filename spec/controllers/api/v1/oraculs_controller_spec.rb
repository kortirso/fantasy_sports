# frozen_string_literal: true

describe Api::V1::OraculsController do
  describe 'GET#index' do
    it_behaves_like 'required api auth'
    it_behaves_like 'required api email confirmation'
    it_behaves_like 'required api available email'

    context 'for logged users' do
      let!(:user) { create :user }
      let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }

      before do
        create_list :oracul, 2
        create :oracul, user: user
      end

      it 'returns oracul data', :aggregate_failures do
        get :index, params: {
          api_access_token: access_token, response_include_fields: 'name,oracul_place_id'
        }

        expect(response).to have_http_status :ok

        attributes = response.parsed_body.dig('oraculs', 'data', 0, 'attributes')
        expect(response.parsed_body.dig('oraculs', 'data').size).to eq 1
        expect(attributes['id']).to be_nil
        expect(attributes['name']).not_to be_nil
        expect(attributes['oracul_place_id']).not_to be_nil
      end
    end

    def do_request(access_token=nil)
      get :index, params: { api_access_token: access_token }.compact
    end
  end

  describe 'POST#create' do
    it_behaves_like 'required api auth'
    it_behaves_like 'required api email confirmation'
    it_behaves_like 'required api available email'

    context 'for logged users' do
      let!(:user) { create :user }
      let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }

      context 'for not existing oracul place' do
        it 'does not create oracul', :aggregate_failures do
          expect { do_request(access_token) }.not_to change(Oracul, :count)
          expect(response).to have_http_status :not_found
          expect(response.parsed_body.dig('errors', 0)).to eq 'Not found'
        end
      end

      context 'for existing oracul place' do
        context 'for season' do
          let!(:season) { create :season }
          let!(:week) { create :week, season: season, status: Week::COMING }
          let!(:oracul_place) { create :oracul_place, placeable: season }

          before do
            create :oracul_league, leagueable: nil, oracul_place: oracul_place, name: 'Delphi'

            create_list :game, 3, week: week
          end

          context 'for invalid params' do
            let(:request) {
              post :create, params: {
                oracul: { name: '' }, oracul_place_id: oracul_place.id, api_access_token: access_token
              }
            }

            it 'does not create oracul', :aggregate_failures do
              expect { request }.not_to change(Oracul, :count)
              expect(response).to have_http_status :ok
              expect(response.parsed_body.dig('errors', 0)).to eq 'Name must be filled'
            end
          end

          context 'for existing oracul' do
            let(:request) {
              post :create, params: {
                oracul: { name: 'Name' }, oracul_place_id: oracul_place.id, api_access_token: access_token
              }
            }

            before { create :oracul, user: user, oracul_place: oracul_place }

            it 'does not create oracul', :aggregate_failures do
              expect { request }.not_to change(Oracul, :count)
              expect(response).to have_http_status :ok
              expect(response.parsed_body.dig('errors', 0)).to eq 'Oracul already exists'
            end
          end

          context 'for valid params' do
            let(:request) {
              post :create, params: {
                oracul: { name: 'Name' }, oracul_place_id: oracul_place.id, api_access_token: access_token
              }
            }

            it 'creates oracul', :aggregate_failures do
              expect { request }.to(
                change(user.oraculs, :count).by(1)
                  .and(change(Oraculs::Lineup, :count).by(1))
                  .and(change(Oraculs::Forecast, :count).by(3))
              )
              expect(response).to have_http_status :ok
              expect(response.parsed_body['errors']).to be_nil
            end
          end
        end

        context 'for cup' do
          let!(:cup) { create :cup }
          let!(:cups_round) { create :cups_round, cup: cup, status: Week::COMING }
          let!(:oracul_place) { create :oracul_place, placeable: cup }

          before do
            create :oracul_league, leagueable: nil, oracul_place: oracul_place, name: 'Delphi'

            create_list :cups_pair, 3, cups_round: cups_round
          end

          context 'for invalid params' do
            let(:request) {
              post :create, params: {
                oracul: { name: '' }, oracul_place_id: oracul_place.id, api_access_token: access_token
              }
            }

            it 'does not create oracul', :aggregate_failures do
              expect { request }.not_to change(Oracul, :count)
              expect(response).to have_http_status :ok
              expect(response.parsed_body.dig('errors', 0)).to eq 'Name must be filled'
            end
          end

          context 'for existing oracul' do
            let(:request) {
              post :create, params: {
                oracul: { name: 'Name' }, oracul_place_id: oracul_place.id, api_access_token: access_token
              }
            }

            before { create :oracul, user: user, oracul_place: oracul_place }

            it 'does not create oracul', :aggregate_failures do
              expect { request }.not_to change(Oracul, :count)
              expect(response).to have_http_status :ok
              expect(response.parsed_body.dig('errors', 0)).to eq 'Oracul already exists'
            end
          end

          context 'for valid params' do
            let(:request) {
              post :create, params: {
                oracul: { name: 'Name' }, oracul_place_id: oracul_place.id, api_access_token: access_token
              }
            }

            it 'creates oracul', :aggregate_failures do
              expect { request }.to(
                change(user.oraculs, :count).by(1)
                  .and(change(Oraculs::Lineup, :count).by(1))
                  .and(change(Oraculs::Forecast, :count).by(3))
              )
              expect(response).to have_http_status :ok
              expect(response.parsed_body['errors']).to be_nil
            end
          end
        end
      end
    end

    def do_request(access_token=nil)
      post :create, params: {
        oracul_place_id: 'unexisting', oracul: { name: 'Name' }, api_access_token: access_token
      }.compact
    end
  end
end
