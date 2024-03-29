# frozen_string_literal: true

describe Api::V1::UsersController do
  describe 'POST#create' do
    context 'for invalid credentials' do
      let(:request) { post :create, params: { user: { email: '', password: '1' } } }

      it 'does not create user', :aggregate_failures do
        expect { request }.not_to change(User, :count)
        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'for short password' do
      let(:request) { post :create, params: { user: { email: 'user@gmail.com', password: '1' } } }

      it 'does not create new user', :aggregate_failures do
        expect { request }.not_to change(User, :count)
        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'without password confirmation' do
      let(:request) { post :create, params: { user: { email: 'user@gmail.com', password: '12345678' } } }

      it 'does not create new user', :aggregate_failures do
        expect { request }.not_to change(User, :count)
        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'for existing user' do
      let!(:user) { create :user }
      let(:request) {
        post :create, params: { user: { email: user.email, password: '12345678', password_confirmation: '12345678' } }
      }

      it 'does not create new user', :aggregate_failures do
        expect { request }.not_to change(User, :count)
        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'for valid data' do
      let(:user_params) { { email: ' useR@gmail.com ', password: '12345678', password_confirmation: '12345678' } }
      let(:request) { post :create, params: { user: user_params } }

      it 'creates new user', :aggregate_failures do
        expect { request }.to change(User, :count).by(1)
        expect(User.last.email).to eq 'user@gmail.com'
        expect(response).to have_http_status :created
        expect(response.parsed_body.dig('user', 'data', 'attributes', 'access_token')).not_to be_blank
      end

      context 'for banned email' do
        before { create :banned_email, value: 'user@gmail.com' }

        it 'does not create new user', :aggregate_failures do
          expect { request }.not_to change(User, :count)
          expect(response).to have_http_status :unprocessable_entity
        end
      end
    end
  end

  describe 'PATCH#update' do
    it_behaves_like 'required api auth'

    context 'for logged users' do
      let!(:user) { create :user }
      let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }

      before { allow(Users::DestroyJob).to receive(:perform_later) }

      it 'destroys user', :aggregate_failures do
        do_request(access_token)

        expect(Users::DestroyJob).to have_received(:perform_later).with(id: user.id)
        expect(response).to have_http_status :ok
      end
    end

    def do_request(access_token=nil)
      delete :destroy, params: { api_access_token: access_token }.compact
    end
  end

  describe 'DELETE#destroy' do
    it_behaves_like 'required api auth'
    it_behaves_like 'required api available email'

    context 'for logged users' do
      let!(:user) { create :user, locale: 'en' }
      let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }

      context 'for invalid params' do
        it 'does not update user', :aggregate_failures do
          patch :update, params: { user: { locale: 'es' }, api_access_token: access_token }

          expect(user.reload.locale).to eq 'en'
          expect(response).to have_http_status :unprocessable_entity
        end
      end

      context 'for valid params' do
        it 'updates user', :aggregate_failures do
          patch :update, params: { user: { locale: 'ru' }, api_access_token: access_token }

          expect(user.reload.locale).to eq 'ru'
          expect(response).to have_http_status :ok
        end
      end
    end

    def do_request(access_token=nil)
      patch :update, params: { user: { locale: 'en' }, api_access_token: access_token }.compact
    end
  end
end
