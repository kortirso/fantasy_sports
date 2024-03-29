# frozen_string_literal: true

describe Api::V1::WeeksController do
  describe 'GET#show' do
    it_behaves_like 'required api auth'
    it_behaves_like 'required api available email'

    context 'for logged users' do
      let!(:user) { create :user }
      let!(:week) { create :week }
      let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }

      context 'for not existing week' do
        it 'returns not found error' do
          do_request(access_token)

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing week' do
        it 'returns week data', :aggregate_failures do
          get :show, params: {
            id: week.id, api_access_token: access_token, response_include_fields: 'id,position,deadline_at'
          }

          expect(response).to have_http_status :ok

          attributes = response.parsed_body.dig('week', 'data', 'attributes')
          expect(attributes['id']).not_to be_nil
          expect(attributes['position']).not_to be_nil
          expect(attributes['deadline_at']).not_to be_nil
        end
      end
    end

    def do_request(access_token=nil)
      get :show, params: { id: 'unexisting', api_access_token: access_token }.compact
    end
  end
end
