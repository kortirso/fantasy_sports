# frozen_string_literal: true

describe Api::V1::LeaguesController do
  describe 'GET#index' do
    it_behaves_like 'required api auth'
    it_behaves_like 'required api email confirmation'
    it_behaves_like 'required api available email'

    context 'for logged users' do
      let!(:user) { create :user }
      let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }

      before { create_list :league, 2 }

      it 'returns leagues data', :aggregate_failures do
        get :index, params: {
          api_access_token: access_token, response_include_fields: 'id,name,sport_kind,slug'
        }

        expect(response).to have_http_status :ok

        attributes = response.parsed_body.dig('leagues', 'data', 0, 'attributes')
        expect(attributes['id']).not_to be_nil
        expect(attributes['name']).not_to be_nil
        expect(attributes['sport_kind']).not_to be_nil
        expect(attributes['slug']).not_to be_nil
      end
    end

    def do_request(access_token=nil)
      get :index, params: { api_access_token: access_token }.compact
    end
  end
end
