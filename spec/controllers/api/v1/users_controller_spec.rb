# frozen_string_literal: true

describe Api::V1::UsersController do
  describe 'POST#create' do
    context 'for invalid credentials' do
      let(:request) { post :create, params: { user: { email: '', password: '1' } } }

      it 'does not create user', :aggregate_failures do
        expect { request }.not_to change(User, :count)
        expect(response).to have_http_status :bad_request
      end
    end

    context 'for short password' do
      let(:request) { post :create, params: { user: { email: 'user@gmail.com', password: '1' } } }

      it 'does not create new user', :aggregate_failures do
        expect { request }.not_to change(User, :count)
        expect(response).to have_http_status :bad_request
      end
    end

    context 'without password confirmation' do
      let(:request) { post :create, params: { user: { email: 'user@gmail.com', password: '12345678' } } }

      it 'does not create new user', :aggregate_failures do
        expect { request }.not_to change(User, :count)
        expect(response).to have_http_status :bad_request
      end
    end

    context 'for existing user' do
      let!(:user) { create :user }
      let(:request) {
        post :create, params: { user: { email: user.email, password: '12345678', password_confirmation: '12345678' } }
      }

      it 'does not create new user', :aggregate_failures do
        expect { request }.not_to change(User, :count)
        expect(response).to have_http_status :bad_request
      end
    end

    context 'for valid data' do
      let(:user_params) { { email: ' useR@gmail.com ', password: '12345678', password_confirmation: '12345678' } }
      let(:request) { post :create, params: { user: user_params } }

      it 'creates new user', :aggregate_failures do
        expect { request }.to change(User, :count).by(1)
        expect(User.last.email).to eq 'user@gmail.com'
        expect(response).to have_http_status :created
        expect(response.parsed_body['access_token']).not_to be_blank
      end

      context 'for banned email' do
        before { create :banned_email, value: 'user@gmail.com' }

        it 'does not create new user', :aggregate_failures do
          expect { request }.not_to change(User, :count)
          expect(response).to have_http_status :bad_request
        end
      end
    end
  end
end
