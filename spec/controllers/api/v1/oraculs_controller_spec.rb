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
        expect(attributes['uuid']).to be_nil
        expect(attributes['name']).not_to be_nil
        expect(attributes['oracul_place_id']).not_to be_nil
      end
    end

    def do_request(access_token=nil)
      get :index, params: { api_access_token: access_token }.compact
    end
  end
end
