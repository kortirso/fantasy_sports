# frozen_string_literal: true

describe Api::V1::Users::MeController do
  describe 'GET#index' do
    it_behaves_like 'required api auth'

    context 'for logged users' do
      let!(:user) { create :user }
      let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }

      it 'returns user data', :aggregate_failures do
        get :index, params: { api_access_token: access_token }

        expect(response).to have_http_status :ok

        attributes = response.parsed_body.dig('user', 'data', 'attributes')
        expect(attributes['email']).to be_nil
        expect(attributes['access_token']).to be_nil
        expect(attributes['confirmed']).to be_truthy
        expect(attributes['banned']).to be_falsy
      end

      context 'with forbidden field in response include fields' do
        it 'returns user data except forbidden fields', :aggregate_failures do
          get :index, params: { api_access_token: access_token, response_include_fields: 'email,access_token' }

          expect(response).to have_http_status :ok

          attributes = response.parsed_body.dig('user', 'data', 'attributes')
          expect(attributes['email']).not_to be_nil
          expect(attributes['access_token']).to be_nil
          expect(attributes['confirmed']).to be_nil
          expect(attributes['banned']).to be_nil
        end
      end

      context 'with forbidden field in response exclude fields' do
        it 'returns user data except forbidden fields', :aggregate_failures do
          get :index, params: { api_access_token: access_token, response_exclude_fields: 'email' }

          expect(response).to have_http_status :ok

          attributes = response.parsed_body.dig('user', 'data', 'attributes')
          expect(attributes['email']).to be_nil
          expect(attributes['access_token']).to be_nil
          expect(attributes['confirmed']).to be_truthy
          expect(attributes['banned']).to be_falsy
        end
      end
    end

    def do_request
      get :index
    end
  end
end
