# frozen_string_literal: true

describe Api::V1::GamesController do
  describe 'GET#index' do
    it_behaves_like 'required api auth'
    it_behaves_like 'required api available email'

    context 'for logged users' do
      let!(:user) { create :user }
      let!(:week) { create :week }
      let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }

      before { create_list :game, 2, week: week }

      it 'returns games data', :aggregate_failures do
        get :index, params: {
          api_access_token: access_token, response_include_fields: 'id,points,predictable'
        }

        expect(response).to have_http_status :ok

        attributes = response.parsed_body.dig('games', 'data', 0, 'attributes')
        expect(attributes['id']).not_to be_nil
        expect(attributes['points']).not_to be_nil
        expect(attributes['predictable']).not_to be_nil
      end
    end

    def do_request(access_token=nil)
      get :index, params: { api_access_token: access_token }.compact
    end
  end
end
