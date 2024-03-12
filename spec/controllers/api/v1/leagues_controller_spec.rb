# frozen_string_literal: true

describe Api::V1::LeaguesController do
  describe 'GET#index' do
    it_behaves_like 'required api auth'

    context 'for logged users' do
      let!(:user) { create :user }
      let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }

      before { create_list :league, 2 }

      it 'returns leagues data', :aggregate_failures do
        get :index, params: {
          access_token: access_token, response_include_fields: 'id,name,sport_kind,background_url'
        }

        expect(response).to have_http_status :ok

        attributes = response.parsed_body.dig('leagues', 'data', 0, 'attributes')
        expect(attributes['id']).not_to be_nil
        expect(attributes['name']).not_to be_nil
        expect(attributes['sport_kind']).not_to be_nil
        expect(attributes['background_url']).not_to be_nil
      end
    end

    def do_request
      get :index
    end
  end
end