# frozen_string_literal: true

describe Api::Frontend::OraculsController do
  describe 'POST#create' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'

    context 'for logged users' do
      sign_in_user

      context 'for not existing oracul place' do
        it 'does not create oracul', :aggregate_failures do
          expect { do_request }.not_to change(Oracul, :count)
          expect(response).to have_http_status :not_found
          expect(response.parsed_body.dig('errors', 0)).to eq 'Page is not found'
        end
      end

      context 'for existing oracul place' do
        let!(:oracul_place) { create :oracul_place }

        before { create :oracul_league, leagueable: nil, oracul_place: oracul_place, name: 'Delphi' }

        context 'for invalid params' do
          let(:request) {
            post :create, params: { oracul: { name: '' }, oracul_place_id: oracul_place.uuid }, format: :json
          }

          it 'does not create oracul', :aggregate_failures do
            expect { request }.not_to change(Oracul, :count)
            expect(response).to have_http_status :ok
            expect(response.parsed_body.dig('errors', 0)).to eq 'Name must be filled'
          end
        end

        context 'for existing oracul' do
          let(:request) {
            post :create, params: { oracul: { name: 'Name' }, oracul_place_id: oracul_place.uuid }, format: :json
          }

          before { create :oracul, user: @current_user, oracul_place: oracul_place }

          it 'does not create oracul', :aggregate_failures do
            expect { request }.not_to change(Oracul, :count)
            expect(response).to have_http_status :ok
            expect(response.parsed_body.dig('errors', 0)).to eq 'Oracul already exists'
          end
        end

        context 'for valid params' do
          let(:request) {
            post :create, params: { oracul: { name: 'Name' }, oracul_place_id: oracul_place.uuid }, format: :json
          }

          it 'creates oracul', :aggregate_failures do
            expect { request }.to change(@current_user.oraculs, :count).by(1)
            expect(response).to have_http_status :ok
            expect(response.parsed_body['errors']).to be_nil
          end
        end
      end
    end

    def do_request
      post :create, params: { oracul: { name: 'Name' }, oracul_place_id: 'unexisting' }, format: :json
    end
  end
end
