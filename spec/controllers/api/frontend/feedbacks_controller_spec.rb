# frozen_string_literal: true

describe Api::Frontend::FeedbacksController do
  describe 'POST#create' do
    it_behaves_like 'required auth'
    it_behaves_like 'required available email'

    context 'for logged users' do
      sign_in_user

      context 'for invalid params' do
        let(:request) { post :create, params: { feedback: { title: 'Title', description: '' } }, format: :json }

        it 'does not create feedback', :aggregate_failures do
          expect { request }.not_to change(Feedback, :count)
          expect(response).to have_http_status :ok
          expect(response.parsed_body.dig('errors', 0)).to eq 'Description must be filled'
        end
      end

      context 'for valid params' do
        let(:request) { post :create, params: { feedback: { title: 'Title', description: 'Text' } }, format: :json }

        it 'creates feedback', :aggregate_failures do
          expect { request }.to change(@current_user.feedbacks, :count).by(1)
          expect(response).to have_http_status :ok
          expect(response.parsed_body['errors']).to be_nil
        end
      end
    end

    def do_request
      post :create, params: { feedback: { title: 'Title', description: 'Text' } }, format: :json
    end
  end
end
