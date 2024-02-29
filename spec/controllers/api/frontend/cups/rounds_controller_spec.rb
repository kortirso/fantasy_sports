# frozen_string_literal: true

describe Api::Frontend::Cups::RoundsController do
  describe 'GET#show' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'

    context 'for logged users' do
      sign_in_user

      context 'for not existing cups round' do
        it 'returns json not_found status with errors' do
          do_request

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing cups round' do
        let!(:cups_round) { create :cups_round }

        before { create :cups_pair, cups_round: cups_round }

        it 'returns json ok status', :aggregate_failures do
          get :show, params: { id: cups_round.uuid }

          expect(response).to have_http_status :ok
          %w[uuid games].each do |attr|
            expect(response.body).to have_json_path("cups_round/data/attributes/#{attr}")
          end
          %w[uuid points start_at home_name visitor_name predictable].each do |attr|
            expect(response.body).to have_json_path("cups_round/data/attributes/games/data/0/attributes/#{attr}")
          end
        end
      end
    end

    def do_request
      get :show, params: { id: 'unexisting' }
    end
  end
end
