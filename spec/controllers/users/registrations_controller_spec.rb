# frozen_string_literal: true

describe Users::RegistrationsController do
  describe 'GET#new' do
    it 'renders new template' do
      get :new, params: { locale: 'en' }

      expect(response).to render_template :new
    end
  end

  describe 'GET#new_username' do
    it 'renders new template' do
      get :new_username, params: { locale: 'en' }

      expect(response).to render_template :new_username
    end
  end

  describe 'POST#create' do
    context 'without credentials' do
      let(:request) { post :create, params: { user: { password: '1' }, locale: 'en' } }

      it 'does not create new user', :aggregate_failures do
        expect { request }.not_to change(User, :count)
        expect(response).to redirect_to users_sign_up_path
      end
    end

    context 'for email registration' do
      context 'for invalid credentials' do
        let(:request) { post :create, params: { user: { email: '', password: '1' }, locale: 'en' } }

        it 'does not create new user', :aggregate_failures do
          expect { request }.not_to change(User, :count)
          expect(response).to redirect_to users_sign_up_path
        end
      end

      context 'for short password' do
        let(:request) { post :create, params: { user: { email: 'user@gmail.com', password: '1' }, locale: 'en' } }

        it 'does not create new user', :aggregate_failures do
          expect { request }.not_to change(User, :count)
          expect(response).to redirect_to users_sign_up_path
        end
      end

      context 'without password confirmation' do
        let(:request) { post :create, params: { user: { email: 'user@gmail.com', password: '12345678' } } }

        it 'does not create new user', :aggregate_failures do
          expect { request }.not_to change(User, :count)
          expect(response).to redirect_to users_sign_up_path
        end
      end

      context 'for existing user' do
        let!(:user) { create :user }
        let(:request) {
          post :create, params: {
            user: { email: user.email, password: '12345678', password_confirmation: '12345678' }, locale: 'en'
          }
        }

        it 'does not create new user', :aggregate_failures do
          expect { request }.not_to change(User, :count)
          expect(response).to redirect_to users_sign_up_path
        end
      end

      context 'for valid data' do
        let(:user_params) { { email: ' useR@gmail.com ', password: '12345678', password_confirmation: '12345678' } }
        let(:request) { post :create, params: { user: user_params, locale: 'en' } }

        it 'creates new user', :aggregate_failures do
          expect { request }.to change(User, :count).by(1)
          expect(User.last.email).to eq 'user@gmail.com'
          expect(response).to redirect_to draft_players_path
        end

        context 'for banned email' do
          before { create :banned_email, value: 'user@gmail.com' }

          it 'does not create new user', :aggregate_failures do
            expect { request }.not_to change(User, :count)
            expect(response).to redirect_to users_sign_up_path
          end
        end
      end
    end

    context 'for username registration' do
      context 'for blank username' do
        let(:request) { post :create, params: { user: { username: '', password: '1' }, locale: 'en' } }

        it 'does not create new user', :aggregate_failures do
          expect { request }.not_to change(User, :count)
          expect(response).to redirect_to users_sign_up_path
        end
      end

      context 'for invalid username format' do
        let(:request) { post :create, params: { user: { username: 'user.name', password: '1' }, locale: 'en' } }

        it 'does not create new user', :aggregate_failures do
          expect { request }.not_to change(User, :count)
          expect(response).to redirect_to users_sign_up_path
        end
      end

      context 'for short password' do
        let(:request) { post :create, params: { user: { username: 'user', password: '1' }, locale: 'en' } }

        it 'does not create new user', :aggregate_failures do
          expect { request }.not_to change(User, :count)
          expect(response).to redirect_to users_sign_up_path
        end
      end

      context 'without password confirmation' do
        let(:request) { post :create, params: { user: { username: 'user', password: '12345678' }, locale: 'en' } }

        it 'does not create new user', :aggregate_failures do
          expect { request }.not_to change(User, :count)
          expect(response).to redirect_to users_sign_up_path
        end
      end

      context 'for existing user' do
        let!(:user) { create :user }
        let(:request) {
          post :create, params: {
            user: { username: user.username, password: '12345678', password_confirmation: '12345678' }
          }
        }

        it 'does not create new user', :aggregate_failures do
          expect { request }.not_to change(User, :count)
          expect(response).to redirect_to users_sign_up_path
        end
      end

      context 'for valid data' do
        let(:user_params) { { username: 'user-name', password: '12345678', password_confirmation: '12345678' } }
        let(:request) { post :create, params: { user: user_params, locale: 'en' } }

        it 'creates new user', :aggregate_failures do
          expect { request }.to change(User, :count).by(1)
          expect(User.last.username).to eq 'user-name'
          expect(response).to redirect_to draft_players_path
        end
      end
    end
  end

  describe 'GET#confirm' do
    it 'renders confirm template' do
      get :confirm, params: { locale: 'en' }

      expect(response).to render_template :confirm
    end
  end
end
