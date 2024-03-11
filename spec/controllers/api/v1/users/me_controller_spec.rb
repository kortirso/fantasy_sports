# frozen_string_literal: true

describe Api::V1::Users::MeController do
  describe 'GET#index' do
    it_behaves_like 'required api auth'

    context 'for logged users' do
      let!(:user) { create :user }
      let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }

      it 'returns user data', :aggregate_failures do
        get :index, params: { access_token: access_token }

        expect(response).to have_http_status :ok

        attributes = response.parsed_body.dig('user', 'data', 'attributes')
        expect(attributes['access_token']).to be_nil
        expect(attributes['confirmed']).to be_truthy
        expect(attributes['banned']).to be_falsy
      end
    end

    def do_request
      get :index
    end
  end
end
