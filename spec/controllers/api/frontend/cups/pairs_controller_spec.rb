# frozen_string_literal: true

describe Api::Frontend::Cups::PairsController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'

    context 'for logged users' do
      sign_in_user

      let!(:cups_round) { create :cups_round }

      before { create :cups_pair, cups_round: cups_round }

      it 'returns json ok status', :aggregate_failures do
        get :index, params: { cups_round_id: cups_round.id }

        expect(response).to have_http_status :ok
        %w[id points start_at home_name visitor_name predictable].each do |attr|
          expect(response.body).to have_json_path("cups_pairs/data/0/attributes/#{attr}")
        end
      end
    end

    def do_request
      get :index, params: { cups_round_id: 'unexisting' }
    end
  end
end
